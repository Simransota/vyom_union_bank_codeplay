import json
import os
from typing import Dict, List, Any
from groq import Groq
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import ChatPromptTemplate
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Get API keys from environment variables
gemini_api_key = os.environ.get("GEMINI_API_KEY")
google_api_key = os.environ.get("GOOGLE_API_KEY")
groq_api_key = os.environ.get("GROQ_API_KEY")

if not gemini_api_key:
    print("Error: GEMINI_API_KEY environment variable not set.")
    exit()

llm = ChatGoogleGenerativeAI(model="gemini-1.5-flash", google_api_key=gemini_api_key)


from langchain.chains import GraphCypherQAChain
from langchain_community.graphs import Neo4jGraph
from langchain.prompts import PromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI
import datetime
import dotenv
import os
import warnings

warnings.filterwarnings("ignore")

dotenv.load_dotenv()

# Initialize Neo4j Graph from environment variables
uri = os.environ.get("NEO4J_URI")
user = os.environ.get("NEO4J_USER") 
password = os.environ.get("NEO4J_PASSWORD")

graph = Neo4jGraph(
    url=uri,
    username=user,
    password=password
)

# Initialize the Cohere LLM
gemini_llm = ChatGoogleGenerativeAI(model="gemini-1.5-flash")

prompt_template = """
Given the following schema of a Neo4j graph database related to banking operations, which includes branches, employees, queries, departments, categories, subdepartments, and customers:

Nodes:

Branch (Properties: branch_id, branch_city, branch_address, branch_state, branch_loc, employee_cnt)
Employee (Properties: employee_id, employee_name, employee_email, employee_number, branch_id, dept_name)
Query (Properties: query_id, query_level, complete_time, waiting_time, redirected, created, updated, estimated_time, priority_level, language)
Department (Properties: dept_id, dept_name, employee_cnt)
Category (Properties: category_id, name)
SubDepartment (Properties: subdept_id, name)
Customer (Properties: customer_id, customer_name, balance, cbil, age, customer_loc)
Relationships:

(Employee)-[:WORKS_AT]->(Branch)
(Employee)-[:BELONGS_TO_DEPT]->(Department)
(Employee)-[:BELONGS_TO_SUBDEPT]->(Department)
(Customer)-[:OPENED_ACCOUNT_AT]->(Branch)
(Query)-[:HAS_CATEGORY]->(Category)
(Query)-[:HAS_SUBDEPARTMENT]->(SubDepartment)
(Query)-[:ASSOCIATED_WITH_BRANCH]->(Branch)
(Query)-[:ASSOCIATED_WITH_DEPARTMENT]->(Department)
(Query)-[:HANDLED_BY]->(Employee)
(Query)-[:RAISED_BY]->(Customer)
(Category)-[:IS_FROM]->(Department)
(SubDepartment)-[:CHILD_OF]->(Department)
Note:

Financial data (e.g., customer balance) must be handled with NULL safety using CASE WHEN … ELSE statements.
Nodes like Employee, Query, and Customer can have multiple relationships.
Use undirected node connections for relationships (e.g., MATCH (e:Employee)-[:HANDLED_BY]-(q:Query)) COMPULSORILY.
Always verify relationships dynamically before accessing properties.
When performing queries relative to the current time, be aware that the server timezone is UTC.
Use OPTIONAL MATCH to include all nodes, apply COUNT() for relationships, filter with WHERE COUNT(rel) = 0, and handle nulls using CASE to ensure accurate results.
NOTE FATAL:
Always pass all needed variables through WITH before WHERE to avoid scoping issues. Example: WITH b, c, cbil_score WHERE cbil_score > 300 ensures c is accessible.

Sample input:Queries in the last 10 days?

Generated Cipher Query:
{answer_query}

Sample input 2: Employees who helped the top 5 highest cbil score person

Generated Cipher Query:
{answer_query2}

User Question: {query}

Generate a Cypher query that:

Handles NULL values appropriately using CASE WHEN … ELSE statements.
Includes relevant filtering based on user input.
Orders the results appropriately for readability.
Uses LIMIT when needed to optimize performance.
Important:

Return only the pure Cypher query without any markdown or additional formatting.
Use error handling with CASE for financial amounts.
You Cannot use BETWEEN
Always include ORDER BY and LIMIT clauses when applicable.
Ensure relationship directions are handled correctly and type conversions are applied as required.
Cypher Query:
"""

prompt = PromptTemplate(template=prompt_template, input_variables=["query"])

def generate_cypher_query(user_query):
    """
    Function to generate a Cypher query from user input using a Neo4j schema.
    """
    try:
        chain = GraphCypherQAChain.from_llm(
            llm=gemini_llm,
            graph=graph,
            verbose=True,
            cypher_prompt=prompt,
            return_direct=True,
            allow_dangerous_requests=True
        )
        answer_query ="""
        MATCH (q:Query)-[:RAISED_BY]-(c:Customer)
        WHERE datetime(q.created) > datetime({date: date() - duration({days: 10})})
        RETURN (Think before returning not a lot not too less)
        CASE WHEN c.balance IS NULL THEN 0 ELSE c.balance END AS balance,
        CASE WHEN c.cbil IS NULL THEN 0 ELSE c.cbil END AS cbil,
        c.age, c.customer_loc
        ORDER BY datetime(q.created) DESC
        LIMIT 100
        """
        answer_query2 ="""
        MATCH (c:Customer)
WITH c, CASE WHEN c.cbil IS NULL THEN 0 ELSE c.cbil END AS cbil_score
ORDER BY cbil_score DESC
LIMIT 5
MATCH (c)-[:RAISED_BY]-(q:Query)-[:HANDLED_BY]-(e:Employee)
RETURN e.employee_name, e.employee_email, e.employee_number, COUNT(q) AS queries_handled
ORDER BY queries_handled DESC
"""
        result = chain.invoke({"query": user_query,"answer_query":answer_query,"answer_query2":answer_query2})
        if isinstance(result, dict):
            return result.get('result', '')
        else:
            return str(result)
    except Exception as e:
        print(f"Error generating Cypher query: {str(e)}")
        return None

# Initialize Groq client with API key from environment variables
client = Groq(api_key=groq_api_key)

def transcribe_audio(file_obj, file_name: str):
    """
    Transcribes an audio file using Groq Whisper.
    Args:
        file_obj (BytesIO): The file object in memory.
        file_name (str): The name of the file.
    Returns:
        dict: Status, filename, and transcription.
    """
    try:
        # Transcribe using Groq API
        transcription = client.audio.transcriptions.create(
            file=(file_name, file_obj.read()),  # Read file content
            model="whisper-large-v3",
            response_format="json",
            language="en",
            temperature=0.0
        )
        return {
            "status": "success",
            "filename": file_name,
            "transcription": transcription.text
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}