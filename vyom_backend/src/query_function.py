banking_map = {
    "Credit": {
        "sub_branches": [
            "Retail Loans",
            "Corporate Loans",
            "Credit Cards",
            "Mortgage & Secured Loans",
            "Microfinance & Agricultural Loans"
        ],
        "categories": [
            "Home Loan",
            "Car Loan",
            "Personal Loan",
            "Education Loan",
            "Loan Against Property",
            "Working Capital Loan",
            "Credit Limit Increase",
            "Reward Points Inquiry"
        ]
    },
    "General Banking": {
        "sub_branches": [
            "Accounts & Deposits",
            "Transactions & Payments",
            "Cards & Banking Services",
            "KYC & Documentation",
            "Banking Tech & Digital Services"
        ],
        "categories": [
            "Savings Account",
            "Current Account",
            "Fixed Deposit",
            "Recurring Deposit",
            "NEFT/RTGS/IMPS Issue",
            "Debit Card Activation",
            "Lost/Stolen Card",
            "Net Banking Login Issue",
            "Mobile Banking Issue"
        ]
    },
    "Forex": {
        "sub_branches": [
            "Currency Exchange",
            "International Transactions",
            "Trade Finance",
            "Foreign Investments & NRI Banking"
        ],
        "categories": [
            "Foreign Exchange Rates Inquiry",
            "Cash Currency Exchange",
            "SWIFT Transfer",
            "Letter of Credit",
            "Bank Guarantee",
            "NRE/NRO Account Opening",
            "Repatriation of Funds"
        ]
    },
}

from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate
import json
from src.utils import execute_query
from datetime import datetime
import json
import os
import io
from typing import Dict,Any
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import ChatPromptTemplate
from dotenv import load_dotenv
import datetime
import os
from pathlib import Path        
import random
from src.utils import upload_file_to_supabase
load_dotenv()
# Initialize the Google PaLM LLM
gemini_api_key=os.environ.get("GEMINI_API_KEY")
llm = ChatGoogleGenerativeAI(model="gemini-1.5-flash", google_api_key=gemini_api_key)

# Create a prompt template
template = """
You are a Bank employee and have 3 tasks:
1> Generate a Title and a short concise description summary for the following query dont put external information:
2> Assign it a query complexity level as follows:
    0:For basic queries which can be given via RAG or a DB function eg:What are the bank timings
    1:For queries requiring an solvable via a chat eg: What is the interest rate on my savings account
    2.For queries having functionality questions and requiring a voice/video call:eg recommend me a credit card for travel purpose
    3:For queries requiring an immediate assistace via a video/voice call eg:The person has lost his credit card and wants to block it
3> Analyse the sentiment of the query from enum of ['ANGRY', 'IMPATIENT', 'NEUTRAL', 'HAPPY', 'CURIOUS','WORRIED']   
return in json format without /n
"title":,"description","query complexity":
{query}
"""

prompt = PromptTemplate(template=template, input_variables=["query"])

# Replace deprecated LLMChain with RunnableSequence
query_chain = prompt | llm

def generate_query_description(user_query):
    """
    Generate a description for a user query using Gemini model.
    
    Args:
        user_query (str): The user's query text
        
    Returns:
        str: JSON formatted description of the query
    """
    # Replace llm_chain.run with query_chain.invoke and extract content
    response = query_chain.invoke({"query": user_query})
    # For ChatGoogleGenerativeAI, we need to extract the content from the response
    if hasattr(response, 'content'):
        return response.content
    return response

def classify_banking_query(query: str) -> Dict[str, Any]:
    """
    Comprehensive function to classify a banking query in one step.
    Returns a dictionary with main branch, relevant sub-branches, and categories.
    
    Args:
        query: The customer's banking query text
        
    Returns:
        Dict containing:
            - main_branch: Selected main branch
            - sub_branches: List of relevant sub-branches (max 2)
            - categories: List of relevant categories
    """
    # Step 1: Determine main branch
    main_branches_str = ", ".join(banking_map.keys())
    template_main = """You are an AI system designed to classify banking queries. 
    Based on the customer query below, select the most appropriate main branch from the following options: 
    {main_branches}. Respond with only the name of the branch.
    Customer query: "{query}"
    """
    prompt_main = ChatPromptTemplate.from_template(template_main)
    # Replace LLMChain with RunnableSequence
    chain_main = prompt_main | llm
    # Replace .run() with .invoke()
    main_branch = chain_main.invoke({"query": query, "main_branches": main_branches_str}).content.strip()
    
    # Step 2: Determine sub-branches and categories based on main branch
    result = {"main_branch": main_branch, "sub_branches": [], "categories": []}
    
    if main_branch not in banking_map:
        return result
    
    branch_info = banking_map[main_branch]
    sub_branches_str = ", ".join(branch_info["sub_branches"])
    categories_str = ", ".join(branch_info["categories"])

    template_sub = """You are an expert banking query classifier. Based on the customer query and the definitions provided below 
    for the main branch "{main_branch}", identify the most relevant sub-branches and categories. 
    Return your answer as a JSON object with keys "sub_branches" and "categories", where the values are lists of strings. 
    Only include at max most relevant 2 sub-branches IF required and categories that are directly relevant to the query.

    Definitions for {main_branch}:
    Sub-Branches: {sub_branches}
    Categories: {categories}

    Customer query: "{query}"

    Return your answer in this JSON format:
    {{
        "sub_branches": [],
        "categories": []
    }}
    """
    prompt_sub = ChatPromptTemplate.from_template(template_sub)
    chain_sub = prompt_sub | llm
    response = chain_sub.invoke({
        "query": query,
        "main_branch": main_branch,
        "sub_branches": sub_branches_str,
        "categories": categories_str
    }).content

    # Clean up response
    response = response.strip()
    if response.startswith("```json"):
        response = response[len("```json"):].strip()
    if response.endswith("```"):
        response = response[:-len("```")].strip()

    try:
        sub_info = json.loads(response.strip())
        result["sub_branches"] = sub_info.get("sub_branches", [])
        result["categories"] = sub_info.get("categories", [])
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON response: {e}")
        print(f"Raw response: {response}")
    return result

def store_query_as_file(query: str) -> str:
    """
    Store a user query as a text file and upload to Supabase storage.
    
    Args:
        query (str): The user's query text
        
    Returns:
        Dict containing:
            - success (bool): Whether the operation was successful
            - storage_path (str): Path where the file was stored in Supabase
            - url (str): Public URL of the stored file
            - error (str, optional): Error message if unsuccessful
    """
    try:        
        # Create a unique filename using timestamp (without spaces)
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        random_id = random.randint(1,1000)
        filename = f"query_{timestamp}_{random_id}.txt"
        
        # Create a BytesIO object to hold file content in memory
        file_obj = io.BytesIO(query.encode('utf-8'))
        
        # Upload directly to Supabase using the utility function, ensuring no spaces in the path
        # The upload_file_to_supabase function will add a timestamp, but we'll make sure it uses
        # a timestamp format without spaces by passing a properly formatted filename
        response = upload_file_to_supabase(file_obj, f"query_{random_id}")
        
        if response.get("status") == "success":
            url = response.get("url")
            # If URL contains spaces, replace them with %20 for proper URL encoding
            if url and ' ' in url:
                url = url.replace(' ', '%20')
            return url
        else:
            return "error"
    except Exception as e:
        return "error"

def predict_resolution_time(priority_score, dept, sub_dept, service_level):
    """
    Predicts query resolution time based on:
        - priority_score: 1 (highest priority) to 10 (lowest)
        - dept: Department name (e.g., "Credit", "General Banking", "Forex")
        - sub_dept: Sub-Department name within the department
        - service_level: 1 (very easy), 2 (medium), or 3 (hard)
    
    Returns:
        PostgreSQL interval string in format "HH:MM:SS"
    """
    # Predefined base resolution times (in minutes)
    base_times = {
        "Credit": {
            "Retail Loans": {1: 40, 2: 80, 3: 120},
            "Corporate Loans": {1: 35, 2: 70, 3: 105},
            "Credit Cards": {1: 30, 2: 60, 3: 90},
            "Mortgage & Secured Loans": {1: 45, 2: 90, 3: 135},
            "Microfinance & Agricultural Loans": {1: 25, 2: 50, 3: 75}
        },
        "General Banking": {
            "Accounts & Deposits": {1: 10, 2: 20, 3: 30},
            "Transactions & Payments": {1: 15, 2: 30, 3: 45},
            "Cards & Banking Services": {1: 12, 2: 24, 3: 36},
            "KYC & Documentation": {1: 8, 2: 16, 3: 24},
            "Banking Tech & Digital Services": {1: 10, 2: 20, 3: 30}
        },
        "Forex": {
            "Currency Exchange": {1: 5, 2: 10, 3: 15},
            "International Transactions": {1: 8, 2: 16, 3: 24},
            "Trade Finance": {1: 20, 2: 40, 3: 60},
            "Foreign Investments & NRI Banking": {1: 25, 2: 50, 3: 75}
        }
    }
        
    # Retrieve the base resolution time
    base_time = base_times[dept][sub_dept][service_level]
    
    # Compute the priority multiplier (higher priority = lower time)
    # Priority 1 = 0.6x, Priority 5 = 1.0x, Priority 10 = 1.5x
    multiplier = 1 + 0.1 * (priority_score - 5)
    
    # Calculate the final resolution time in minutes
    resolution_time_min = base_time * multiplier
    
    # Convert to hours, minutes, seconds
    hours = int(resolution_time_min // 60)
    minutes = int(resolution_time_min % 60)
    seconds = int((resolution_time_min * 60) % 60)
    
    # Format as PostgreSQL interval string "HH:MM:SS"
    interval_string = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
    
    return interval_string

def process_query_and_save(query_text: str, cust_id: str) -> Dict[str, Any]:
    """
    Process a customer query and save it to the database.
    
    Args:
        query_text (str): The customer's query text
        cust_id (str): Customer UUID from database
    Returns:
        Dict containing the processing result and database operation status
    """
    try:
        # Initialize processing
        current_time = datetime.datetime.now()
        
        # Step 1: Generate query description (title, complexity, sentiment)
        description_result = generate_query_description(query_text)
        try:
            if isinstance(description_result, str):
                description_data = json.loads(description_result)
            else:
                description_data = description_result
                
            title = description_data.get("title", "Untitled Query")
            description = description_data.get("description", query_text[:100])
            query_complexity = int(description_data.get("query complexity", 1))
            query_sentiment = description_data.get("sentiment")
        except (json.JSONDecodeError, ValueError, TypeError) as e:
            print(f"Error parsing description result: {e}")
            title = "Untitled Query"
            description = query_text[:100]
            query_complexity = 1
            query_sentiment = "NEUTRAL"
            
        # Step 2: Classify the query (department, sub-department, categories)
        classification = classify_banking_query(query_text)
        department_name = classification.get("main_branch")
        
        # Make sure sub_branches and categories are lists (not sets)
        sub_branches = list(classification.get("sub_branches", []))
        categories = list(classification.get("categories", []))
        
        # Format subdepartments as comma-separated string if more than one
        sub_dept = ", ".join(sub_branches)
        
        # Format categories as comma-separated string
        categories_str = ", ".join(categories) if categories else ""
        
        # Step 3: Store the query text and get URL
        storage_result = store_query_as_file(query_text)
        transcript_url = storage_result

        # Step 4: Calculate estimated resolution time
        # Set priority based on complexity and sentiment
        priority_level = min(10, max(1, 11 - query_complexity * 3))
        if query_sentiment in ["ANGRY", "IMPATIENT"]:
            priority_level = max(1, priority_level - 2)
        elif query_sentiment in ["HAPPY"]:
            priority_level = min(10, priority_level + 1)
            
        # Calculate resolution time in minutes
        # For resolution time calculation, use the first subdepartment if multiple exist
        calculation_sub_dept = sub_branches[0]
        
        # Handle case where sub_dept is not in base_times
        try:
            estimated_time = predict_resolution_time(
                priority_level, 
                department_name, 
                calculation_sub_dept, 
                query_complexity
            )
        except Exception as rt_error:
            print(f"Error calculating resolution time: {rt_error}")
            # Fallback to a default resolution time
        
        # Create activity logs as JSON string
        activity_logs = json.dumps([{
            "timestamp": current_time.isoformat(),
            "action": "Query Created",
            "details": "Customer query received and processed"
        }])
        
        # Create additional details as JSON string
        additional_details = json.dumps({
            "categories": categories,
            "sub_branches": sub_branches,
            "original_query": query_text
        })
        
        # Format date_time as ISO string
        date_time_str = current_time.isoformat()
        
        # Map sentiment to database values
        sentiment_mapping = {
            "ANGRY": "Negative",
            "IMPATIENT": "Negative",
            "NEUTRAL": "Neutral",
            "HAPPY": "Positive",
            "CURIOUS": "Neutral",
            "WORRIED": "Negative"
        }
        db_sentiment = query_sentiment
        
        # Set parameters for SQL query with correct types
        params = (
            cust_id,                   # cust_id (UUID)
            title,                     # title (text)
            description,               # description (text)
            department_name,           # department_name (text)
            sub_dept,                  # subtype (text)
            query_complexity,          # query_level (int)
            priority_level,            # priority_level (int)
            estimated_time,            # estimated_time (interval)
            categories_str,            # categories (text)
            transcript_url,            # transcript_bkturl (text)
            'Active',                  # status (enum)
            db_sentiment,              # query_sentiment (text)
            date_time_str,             # date_time (timestamp)
            activity_logs,             # activity_logs (jsonb)
            additional_details         # additional_details (jsonb)
        )
        
        # SQL query with proper column order matching params
        query = """
        INSERT INTO query (
            cust_id,
            title,
            description,
            department_name,
            subtype,
            query_level,
            priority_level,
            estimated_time,
            categories,
            transcript_bkturl,
            status,
            query_sentiment,
            date_time,
            activity_logs,
            additional_details
        ) VALUES (
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
        ) RETURNING query_id;
        """
        
        try:
            # Execute the query
            result = execute_query(query, params,return_id=True)
            
            # Extract query_id from response
            query_id = result
            return {
                "success": True,
                "query_id": query_id,
            }
        except Exception as db_error:
            print(f"Database error: {str(db_error)}")
            return {
                "success": False,
                "message": "Failed to insert query into database",
                "error": str(db_error),
                "status_code": 500
            }
    
    except Exception as e:
        print(f"Processing error: {str(e)}")
        return {
            "success": False,
            "message": "An error occurred while processing the request",
            "error": str(e),
            "status_code": 500
        }

def get_function_return_types():
    """
    Returns a JSON structure documenting the return types of all major functions in this module.
    This helps with debugging and integration.
    """
    return {
        "generate_query_description": {
            "description": "Generates a description for a user query using Gemini model",
            "return_type": "str (JSON string)",
            "example_return": {
                "title": "Credit Card Limit Increase",
                "description": "Request to increase credit limit for upcoming expenses",
                "query complexity": 2,
                "sentiment": "NEUTRAL"
            },
            "possible_issues": "May return malformed JSON requiring additional parsing"
        },
        
        "classify_banking_query": {
            "description": "Classifies a query into banking branches, sub-branches, and categories",
            "return_type": "Dict[str, Any]",
            "example_return": {
                "main_branch": "Credit",
                "sub_branches": ["Credit Cards", "Retail Loans"],
                "categories": ["Credit Limit Increase"]
            },
            "possible_issues": "May return empty lists for sub_branches or categories if classification fails"
        },
        
        "store_query_as_file": {
            "description": "Stores user query as a file in Supabase storage",
            "return_type": "Dict[str, Any]",
            "example_success_return": {
                "success": True,
                "url": "https://example.storage.com/files/query_12345.txt"
            },
            "example_error_return": {
                "success": False,
                "error": "Failed to upload file: permission denied"
            }
        },
        
        "predict_resolution_time": {
            "description": "Predicts query resolution time based on priority and other factors",
            "return_type": "str (PostgreSQL interval format)",
            "example_return": "00:45:30",  # 45 minutes, 30 seconds
            "possible_error_return": "Department 'Unknown' not recognized.",
            "format": "HH:MM:SS"
        },
        
        "process_query_and_save": {
            "description": "Main function that processes a query and saves it to database",
            "return_type": "Dict[str, Any]",
            "example_success_return": {
                "success": True,
                "message": "Query processed and saved successfully",
                "query_id": 12345,
                "status_code": 201
            },
            "example_error_return": {
                "success": False,
                "message": "Failed to insert query into database",
                "error": "duplicate key value violates unique constraint",
                "status_code": 500
            }
        }
    }

# Call this function to print the return types during debugging
if __name__ == "__main__":
    import json
    print(json.dumps(get_function_return_types(), indent=4))
