from src.config import get_pg_connection, release_pg_connection  # Import connection pool functions
from src.config import get_pg_connection,get_redis,release_pg_connection,init_redis,redis_client,sync_redis_client,get_db_connection
import json
import binascii
import io
from asyncpg import PostgresError
from supabase import create_client, Client
import datetime
import random
import os
from dotenv import load_dotenv
import asyncpg
from typing import Any, List, Tuple, Optional, Union
from pydantic import BaseModel, Field
from neo4j import GraphDatabase
import psycopg2
# Load environment variables
load_dotenv()

# Get Supabase credentials from environment variables
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_SERVICE_KEY = os.environ.get("SUPABASE_KEY")
STORAGE_BUCKET = os.environ.get("SUPABASE_STORAGE_BUCKET")

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)

def get_lnglat(wkb_hex):
    """
    Convert a WKB hex string to longitude and latitude coordinates.
    
    Args:
        wkb_hex (str): Hex string representation of a WKB geometry
        
    Returns:
        tuple: (longitude, latitude) coordinates
    """
    geometry = loads(binascii.unhexlify(wkb_hex))
    return (geometry.x, geometry.y)


async def is_redis_active():
    """Check if Redis connection is active."""
    global redis_client
    if redis_client is None:
        await init_redis()  # Ensure Redis is initialized

    try:
        if redis_client and await redis_client.ping():
            return "yes"
        return "no"
    except Exception as e:
        print(f"❌ Redis connection error: {e}")
        return "no"

# Define Pydantic Model for Input Validation
class QueryRequest(BaseModel):
    query: str = Field(..., description="The SQL query to execute")
    params: Optional[Tuple[Any, ...]] = Field(None, description="Query parameters")
    use_cache: bool = Field(False, description="Whether to use Redis caching")
    cache_key: Optional[str] = Field(None, description="Key for caching")
    cache_expiry: int = Field(3600, description="Cache expiry time in seconds")
    return_id: bool = Field(False, description="Return last inserted ID if an INSERT query")


# Async Query Execution Function
async def execute_query(request: QueryRequest) -> Union[int, List[dict], None]:
    """Executes an SQL query asynchronously using asyncpg. Supports Redis caching."""
    conn = await get_pg_connection()
    if conn is None:
        print("❌ Could not get a database connection")
        return None

    try:
        # ✅ Check Redis cache before executing query
        if request.use_cache and request.cache_key and redis_client:
            cached_result = await redis_client.get(request.cache_key)
            if cached_result:
                try:
                    return json.loads(cached_result)
                except json.JSONDecodeError:
                    print(f"Error decoding cached result for key: {request.cache_key}")

        params = request.params or ()  # ✅ Ensure params is always a tuple
        query_upper = request.query.strip().upper()

        if query_upper.startswith("SELECT"):
            results = await conn.fetch(request.query, *params)
            result_data = [dict(row) for row in results]

            # ✅ Store the result in cache
            if request.use_cache and request.cache_key and redis_client:
                await redis_client.setex(
                    request.cache_key, request.cache_expiry, json.dumps(result_data)
                )

            return result_data

        elif "INSERT" in query_upper and request.return_id:
            last_id = await conn.fetchval(request.query, *params)

            # ✅ Store last inserted ID in cache (optional)
            if request.use_cache and request.cache_key and redis_client:
                await redis_client.setex(request.cache_key, request.cache_expiry, json.dumps({"inserted_id": last_id}))

            return last_id

        else:
            result = await conn.execute(request.query, *params)
            affected_rows = int(result.split()[-1]) if "INSERT" in query_upper else result

            # ✅ Store affected rows in cache (optional)
            if request.use_cache and request.cache_key and redis_client:
                await redis_client.setex(request.cache_key, request.cache_expiry, json.dumps({"affected_rows": affected_rows}))

            return affected_rows

    except PostgresError as pg_err:
        print(f"Database error: ❌ {pg_err}")
        return None

    except Exception as e:
        print(f"Unexpected error: ❌ {e}")
        return None

    finally:
        await release_pg_connection(conn)  # ✅ Properly release connection

def execute_query_sync(request: QueryRequest) -> Union[int, List[dict], None]:
    """Executes a SQL query synchronously using psycopg2."""
    # Check cache first
    if request.use_cache and request.cache_key:
        cached_result = sync_redis_client.get(request.cache_key)
        if cached_result:
            try:
                return json.loads(cached_result)
            except json.JSONDecodeError:
                print(f"❌ Error decoding cached data for {request.cache_key}")

    conn = get_db_connection()
    if not conn:
        return None

    try:
        with conn.cursor() as cur:
            cur.execute(request.query, request.params)
            
            # Fetch results if it's a SELECT query
            if request.query.strip().upper().startswith("SELECT"):
                columns = [desc[0] for desc in cur.description]
                results = [dict(zip(columns, row)) for row in cur.fetchall()]
                
                # Cache the result
                if request.use_cache and request.cache_key:
                    sync_redis_client.setex(request.cache_key, request.cache_expiry, json.dumps(results))

                return results

            # Return last inserted ID for INSERT
            elif request.query.strip().upper().startswith("INSERT"):
                conn.commit()
                return cur.fetchone()[0] if cur.description else None

            # Return affected row count for UPDATE/DELETE
            else:
                affected_rows = cur.rowcount
                conn.commit()
                return affected_rows

    except Exception as e:
        print(f"❌ Query execution error: {e}")
        return None
    finally:
        conn.close()


def upload_file_to_supabase(file_obj: io.BytesIO, file_name: str):
    """
    Uploads a file to Supabase Storage.

    Args:
        file_obj (BytesIO): The file object in memory.
        file_name (str): The name of the file.
    Returns:
        dict: Status, uploaded filename, and URLs.
    """
    storage_path = f"uploads/{file_name}-{datetime.datetime.now()}_{random.randint(1,1500)}"  # Define storage path
    try:
        file_obj.seek(0)  # Reset file pointer before reading
        # Upload file object with correct format
        response = supabase.storage.from_(STORAGE_BUCKET).upload(
            storage_path, file_obj.read(), file_options={"content-type": "application/octet-stream"}
        )
        if response:
            public_url = supabase.storage.from_(STORAGE_BUCKET).get_public_url(storage_path)
            return {
                "status": "success",
                "uploaded_as": storage_path,
                "url": public_url,
            }
        else:
            return {"status": "error", "message": "Upload failed."}

    except Exception as e:
        return {"status": "error", "message": str(e)}

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
def execute_cypher_query(query, url, user, pw):
    """Executes a Cypher query using the Neo4j driver."""
    try:
        driver = GraphDatabase.driver(url, auth=(user, pw))  # Create a driver instance
        with driver.session() as session:  # Open a session
            session.run(query)  # Execute the query
        print(f"Query executed successfully: {query[:50]}...")
        return True
    except Exception as e:
        print(f"Error executing query: {query[:50]}...")
        print(f"Error details: {e}")
        return False
    

def initial_insertion_query_neo4j(result, query_complexity, date_time_str, estimated_time, priority_level, language, 
                                db_sentiment, category_str, sub_dept, department_name, cust_id):
    """
    Create a Query node in Neo4j along with its relationships.
    
    Args:
        result: Query ID
        query_complexity: Level of query complexity
        date_time_str: Formatted date time string
        estimated_time: Estimated time to resolve (formatted as a string, e.g., '01:02:59')
        priority_level: Priority level of the query
        language: Language of the query
        db_sentiment: Sentiment analysis result
        category_str: Comma-separated string of categories
        sub_dept: Sub-department ID
        department_name: Department name
        cust_id: Customer ID
    
    Returns:
        List of Cypher queries to execute
    """
    cypher_queries = []

    # Ensure estimated_time is properly formatted as a string
    estimated_time_str = f"'{estimated_time}'"  # Enclose in single quotes

    # Create the Query node
    cypher_queries.append(f"""
    CREATE (q:Query {{
        query_id: {result},
        query_level: {query_complexity},
        redirected: false,
        created: '{date_time_str}',
        updated: '{date_time_str}',
        estimated_time: {estimated_time_str},
        priority_level: {priority_level},
        language: '{language}',
        sentiment: '{db_sentiment}',
        status: 'Active'
    }});
    """)

    # Create HAS_CATEGORY Relationships
    for category in category_str.split(','):
        category = category.strip()  # Remove any extra whitespace
        if category:  # Only process non-empty categories
            cypher_queries.append(f"""
            MATCH (q:Query {{query_id: {result}}})
            MERGE (cat:Category {{category_id: '{category}'}})
            MERGE (q)-[:HAS_CATEGORY]->(cat);
            """)

# Create HAS_SUBDEPARTMENT Relationships
    for sub_department in sub_dept.split(','):  # Split sub_dept if it's a comma-separated string
        sub_department = sub_department.strip()  # Remove any extra whitespace
        if sub_department:  # Only process non-empty sub-departments
            cypher_queries.append(f"""
            MATCH (q:Query {{query_id: {result}}})
            MERGE (sub:SubDepartment {{subdept_id: '{sub_department}'}})
            MERGE (q)-[:HAS_SUBDEPARTMENT]->(sub);
            """)

    # Create ASSOCIATED_WITH_DEPARTMENT Relationships
    cypher_queries.append(f"""
    MATCH (q:Query {{query_id: {result}}})
    MERGE (d:Department {{dept_id: '{department_name}'}})
    MERGE (q)-[:ASSOCIATED_WITH_DEPARTMENT]->(d);
    """)

    # Create RAISED_BY Relationships
    cypher_queries.append(f"""
    MATCH (q:Query {{query_id: {result}}}), (c:Customer {{customer_id: '{cust_id}'}})
    MERGE (q)-[:RAISED_BY]->(c);
    """)
    return cypher_queries

def employee_query_neo4j(result, employee_id=None, branch_id=None):
    """
    Create ASSOCIATED_WITH_BRANCH and HANDLED_BY relationships in Neo4j.
    
    Args:
        result: Query ID
        employee_id: Optional Employee ID
        branch_id: Optional Branch ID
    
    Returns:
        List of Cypher query strings
    """
    queries = []
    
    if branch_id is not None:
        queries.append(f"MATCH (q:Query {{query_id: {result}}}), (b:Branch {{branch_id: {branch_id}}}) MERGE (q)-[:ASSOCIATED_WITH_BRANCH]->(b);")
    
    if employee_id is not None:
        queries.append(f"MATCH (q:Query {{query_id: {result}}}), (e:Employee {{employee_id: {employee_id}}}) MERGE (q)-[:HANDLED_BY]->(e);")
    return queries


def create_customer_neo4j(customer_id, customer_name, balance, cbil, age, email, phone_no, 
                        push_enabled=False, join_date=None, longitude=None, latitude=None):
    """
    Create a Customer node in Neo4j.
    
    Args:
        customer_id: Unique identifier for the customer
        customer_name: Full name of the customer
        balance: Customer's account balance
        cbil: Customer's credit score
        age: Customer's age
        email: Customer's email address
        phone_no: Customer's phone number
        push_enabled: Whether push notifications are enabled (default: False)
        join_date: Date when customer joined (default: current date if None)
        longitude: Longitude coordinate (optional)
        latitude: Latitude coordinate (optional)
        url: Neo4j connection URL
        user: Neo4j username
        pw: Neo4j password
    
    Returns:
        bool: Whether the operation was successful
    """
    if join_date is None:
        join_date = datetime.datetime.now().strftime("%Y-%m-%d")
    
    # Build location part of the query
    location_part = ""
    if longitude is not None and latitude is not None:
        location_part = f", customer_loc: point({{longitude: {longitude}, latitude: {latitude}}})"
    
    # Create the Cypher query
    query = f"""
    CREATE (c:Customer {{
        customer_id: "{customer_id}",
        customer_name: "{customer_name}",
        balance: {balance},
        cbil: {cbil},
        age: {age},
        email: "{email}",
        phone_no: "{phone_no}",
        push_enabled: {str(push_enabled).lower()},
        join_date: "{join_date}"{location_part}
    }});
    """
    return query