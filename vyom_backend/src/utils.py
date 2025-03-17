from src.config import get_pg_connection, release_pg_connection  # Import connection pool functions
from src.config import redis_client
import psycopg2
import psycopg2.extras
from shapely.wkb import loads
import binascii
import io
from supabase import create_client, Client
import datetime
import random
import os
from dotenv import load_dotenv
import asyncpg
from typing import Any, List, Tuple, Optional, Union

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


def is_redis_active(redis_client):
    """Check if Redis connection is active."""
    try:
        if redis_client.ping():
            return "yes"
        return "no"
    except Exception as e:
        print(f"Redis connection error: {e}")
        return "no"

def execute_query(query, params=None, use_cache=False, cache_key=None, cache_expiry=3600, return_id=False):
    """
    Executes a given SQL query using a connection from the pool.
    
    Args:
        query (str): The SQL query to execute.
        params (tuple, optional): Parameters for parameterized queries (default: None).
        use_cache (bool, optional): Whether to cache the result in Redis (default: False).
        cache_key (str, optional): The key to use for caching in Redis (required if use_cache is True).
        cache_expiry (int, optional): Cache expiry time in seconds (default: 3600 seconds).
        return_id (bool, optional): Whether to return the last inserted ID for INSERT queries (default: False).
    
    Returns:
        If return_id is True and it's an INSERT query: The ID of the last inserted row
        Otherwise: The result of the query as a list of tuples, or None in case of error.
    """
    if use_cache and not cache_key:
        raise ValueError("cache_key is required when use_cache is True")
    if use_cache:
        cached_result = redis_client.get(cache_key)
        if cached_result:
            try:
                # Assuming your result is stored as a JSON-encoded string
                import json
                return json.loads(cached_result)
            except json.JSONDecodeError:
                print(f"Error decoding cached result for key: {cache_key}")
                # Fallback to executing the query and updating the cache
    try:
        conn = get_pg_connection()
        if conn:
            try:
                with conn.cursor() as cur:
                    psycopg2.extras.register_composite("kpi_type", conn) # Register composite type

                    cur.execute(query, params)
                    
                    # Get last inserted ID if it's an INSERT query and return_id is True
                    last_id = None
                    if return_id and query.strip().upper().startswith('INSERT'):
                        cur.execute("SELECT lastval()")
                        last_id = cur.fetchone()[0]
                    
                    # Get result set if query returns data
                    if cur.description:
                        result = cur.fetchall()
                        if use_cache:
                            try:
                                import json
                                redis_client.setex(cache_key, cache_expiry, json.dumps(result))
                            except Exception as cache_err:
                                print(f"Error caching result: {cache_err}")
                    else:
                        result = None

                    conn.commit()
                    
                    # Return last_id if requested, otherwise return result
                    if return_id and last_id is not None:
                        return last_id
                    return result
            except Exception as inner_e:
                print(f"Error executing query: ❌ {inner_e}")
                conn.rollback()
                return None

            finally:
                release_pg_connection(conn)

        else:
            print("Failed to retrieve a connection from the pool: ❌")
            return None

    except Exception as e:
        print(f"Error initializing connection pool: ❌ {e}")
        return None

async def execute_query_async(query: str, params: Optional[Tuple[Any, ...]] = None) -> Union[int, List[dict]]:
    """
    Execute a database query asynchronously
    
    Parameters:
        query (str): SQL query to execute
        params (tuple, optional): Parameters for the SQL query
    
    Returns:
        int or list: The ID of the inserted row (for INSERT operations with RETURNING) 
                    or a list of results (for SELECT operations)
    """
    # Get database connection details from environment variables
    db_host = os.environ.get("DB_HOST", "localhost")
    db_port = os.environ.get("DB_PORT", "5432")
    db_name = os.environ.get("DB_NAME", "postgres")
    db_user = os.environ.get("DB_USER", "postgres")
    db_password = os.environ.get("DB_PASSWORD", "postgres")
    
    conn = None
    try:
        # Connect to the database
        conn = await asyncpg.connect(
            host=db_host,
            port=db_port,
            database=db_name,
            user=db_user,
            password=db_password
        )
        
        if query.strip().upper().startswith("SELECT"):
            # For SELECT queries, return all results
            results = await conn.fetch(query, *params) if params else await conn.fetch(query)
            return [dict(row) for row in results]
        else:
            # For INSERT/UPDATE/DELETE queries, return the ID or affected row count
            if "RETURNING" in query.upper():
                result = await conn.fetchval(query, *params) if params else await conn.fetchval(query)
                return result
            else:
                result = await conn.execute(query, *params) if params else await conn.execute(query)
                return int(result.split()[-1]) if "INSERT" in query.upper() else result
    
    except Exception as e:
        print(f"Database error: {str(e)}")
        raise e
    
    finally:
        # Close the connection
        if conn:
            await conn.close()

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
