
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate,ChatPromptTemplate
import json
import math
import json
import os
import io
from typing import Dict,Any,Optional
from dotenv import load_dotenv
from celery_app import add_query_to_queue
import datetime
import os
from pathlib import Path        
import random
from src.utils import upload_file_to_supabase,banking_map,QueryRequest,execute_cypher_query,execute_query_sync,initial_insertion_query_neo4j
load_dotenv()
# Initialize the Google PaLM LLM
gemini_api_key=os.environ.get("GEMINI_API_KEY")
llm = ChatGoogleGenerativeAI(model="gemini-1.5-flash", google_api_key=gemini_api_key)
graphdb_url = os.environ.get("NEO4J_URI")
username = 'neo4j'
password = os.environ.get("NEO4J_PASSWORD")

def get_customer_priority(cust_id, query_priority):
    """Calculate customer priority score on a scale of 1-20, using Gaussian distribution for age."""
    try:
        # Get customer data from Supabase
        request = QueryRequest(
            query="SELECT bank_balance,cred_score,dob,join_date FROM customer WHERE cust_id = %s",params=(cust_id,),
            use_cache=False, cache_key=None, cache_expiry=3600, return_id=False)
        customer_data_list = execute_query_sync(request)
        # Extract customer data
        if customer_data_list:
            customer_data = customer_data_list[0]
            bank_balance = float(customer_data.get('bank_balance'))
            credit_score = customer_data.get('cred_score')
            dob = customer_data.get('dob')
            join_date = customer_data.get('join_date')
        else:
            return ("error", "No customer data found")
        # Map priority (1-10) to (1-20) scale
        priority_level = query_priority if query_priority is not None else 5        
        account_age_days = (datetime.datetime.now(datetime.timezone.utc) - join_date).days

        # Calculate user age if DOB exists
        if dob:
            today = datetime.datetime.now(datetime.timezone.utc).date()
            birth_date = datetime.datetime(dob.year, dob.month, dob.day).date()
            user_age = (today - birth_date).days // 365  # Convert days to years
        # Define weightage for each factor
        credit_weight = 0.25
        balance_weight = 0.25
        tenure_weight = 0.15
        priority_weight = 0.15
        age_weight = 0.2  # Age weightage

        # Normalize values to 0-100 range
        norm_credit = (credit_score - 300) / 550 * 100  # Credit Score (300-850)
        norm_balance = min(bank_balance / 100000 * 100, 100)  # Bank balance (Capped at 100,000)
        norm_tenure = min(account_age_days / 1825 * 100, 100)  # Tenure (Capped at 5 years)
        norm_priority = priority_level * 10  # Priority level (1-10 to 0-100)
        
        # Age Normalization (Gaussian Curve with peak at 36)
        age_mean = 36  # Peak at 36 years old
        age_std_dev = 10  # Spread (10 years)
        norm_age = math.exp(-((user_age - age_mean) ** 2) / (2 * age_std_dev ** 2)) * 100  # Gaussian Function

        # Calculate raw priority score (0-100 range)
        raw_priority_score = (
            credit_weight * norm_credit +
            balance_weight * norm_balance +
            tenure_weight * norm_tenure +
            priority_weight * norm_priority +
            age_weight * norm_age  # Gaussian-based age score
        )
        
        # Convert raw score (0-100) to (1-20) scale
        priority_1_20 = max(1, min(round(raw_priority_score / 5), 20))
        
        return priority_1_20
    except Exception as e:
        print(f"Error calculating customer priority: {e}")
        return 10  # Default mid-level priority in case of error

def generate_query_description(user_query):
    """
    Generate a description for a user query using Gemini model.
    """
    template = """
    You are a Bank employee and have 3 tasks:
    1> Generate a Title and a short concise description summary for the following query dont put external information:
    2> Assign it a query complexity level as follows:
        0:For basic queries which can be given via RAG or a DB function eg:What are the bank timings
        1:For queries requiring an solvable via a chat eg: What is the interest rate on my savings account
        2.For queries having functionality questions and requiring a voice/video call:eg recommend me a credit card for travel purpose
        3:For queries requiring an immediate assistace via a video/voice call eg:The person has lost his credit card and wants to block it
    3> Analyse the sentiment of the query from enum of ['ANGRY', 'IMPATIENT', 'NEUTRAL', 'HAPPY', 'CURIOUS','WORRIED']   
    return in given format without json formatting
    {{
        "title":,
        "description":,
        "query_complexity":,
        "sentiment":
    }}
    {query}
    """

    prompt = PromptTemplate(template=template, input_variables=["query"])
    query_chain = prompt | llm

    try:
        response = query_chain.invoke({"query": user_query})
        if hasattr(response, 'content') and response.content:
            return response.content
        else:
            raise ValueError("Empty response from Gemini model")
    except Exception as e:
        print(f"Error generating query description: {e}")
        return ValueError

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
    chain_main = prompt_main | llm
    main_branch = chain_main.invoke({"query": query, "main_branches": main_branches_str}).content.strip()
    
    # Step 2: Determine sub-branches and categories based on main branch
    result = {"main_branch": main_branch, "sub_branches": [], "categories": []}
    
    if main_branch not in banking_map:
        return result
    
    branch_info = banking_map[main_branch]
    sub_branches_str = ", ".join(branch_info["sub_branches"])
    categories_str = ", ".join(branch_info["categories"])

    template_sub = """You are an expert banking query classifier. Based on the customer query and the definitions provided below 
    for the main branch "{main_branch}", identify the most relevant sub-branche and categories. 
    Return your answer as a JSON object with keys "sub_branches" and "categories", where the values are lists of strings. 
    Only include at max most relevant sub-branch and as many categories that are directly relevant to the query.

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


def process_query_and_save(query_text: str, cust_id: str,latitude:float,longitude:float,language:str,schedule_time:Optional[datetime.datetime]) -> Dict[str, Any]:
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
                description_result = description_result.strip()
                description_data = json.loads(description_result)
            else:
                description_data = description_result
                
            title = description_data.get("title")
            description = description_data.get("description")
            query_complexity = int(description_data.get("query_complexity"))
            query_sentiment = description_data.get("sentiment")
        except (json.JSONDecodeError, ValueError, TypeError) as e:
            print(f"Error parsing description result: {e}")
        
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
        priority_level = get_customer_priority(cust_id, query_complexity)
        # Calculate resolution time in minutes
        calculation_sub_dept = sub_branches[0]
        
        # Get the location of the user
        geography = f"SRID=4326;POINT({longitude} {latitude})"  # WKT format for geography
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
            "action": "Query received",
            "status": "Pending",
        }])
        
        # Format date_time as ISO string
        date_time_str = current_time.isoformat()
        if schedule_time:
            schedule_time = schedule_time.isoformat()
        # Map sentiment to database values
        sentiment_mapping = {
            "ANGRY": "Negative",
            "IMPATIENT": "Negative",
            "NEUTRAL": "Neutral",
            "HAPPY": "Positive",
            "CURIOUS": "Neutral",
            "WORRIED": "Negative"
        }
        
        db_sentiment = sentiment_mapping.get(query_sentiment, "Neutral")
        
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
            language,                  # language (text)
            geography,                  # location (geography)
            schedule_time if schedule_time else None  # schedule_time (timestamp, optional)
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
            language,
            location,
            schedule_time
        ) VALUES (
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,%s,ST_GeomFromText(%s),%s
        ) RETURNING query_id;
        """
        # Query 1 to make the query node
        try:
            queryobj = QueryRequest(query=query,params=params,use_cache=False,cache_key=None,cache_expiry=3600,return_id=True)
            result = execute_query_sync(queryobj)
            cypher_queries = initial_insertion_query_neo4j(result, query_complexity, date_time_str, estimated_time, priority_level, language, db_sentiment, categories_str, sub_dept, department_name, cust_id)
            for cypy in cypher_queries:
                execute_cypher_query(cypy, graphdb_url, username, password)
            add_query_to_queue(result,priority_level)
            if result:
                return {
                "success": True,
                "message": "Query processed and saved successfully",
                "query_id":result
            }
            else:
                # Log this issue
                print(f"Warning: execute_query did not return an integer ID: {result}")
                query_id = None
            return {
                "success": False,
                "message": "Error processing the query in db",
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