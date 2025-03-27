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

def execute_query_sync(query: str, params: tuple = (), use_cache: bool = False, cache_key: str = None, cache_expiry: int = 3600):
    """Executes a SQL query synchronously using psycopg2."""
    # Check cache first
    if use_cache and cache_key:
        cached_result = sync_redis_client.get(cache_key)
        if cached_result:
            try:
                return json.loads(cached_result)
            except json.JSONDecodeError:
                print(f"❌ Error decoding cached data for {cache_key}")

    conn = get_db_connection()
    if not conn:
        return None

    try:
        with conn.cursor() as cur:
            cur.execute(query, params)
            
            # Fetch results if it's a SELECT query
            if query.strip().upper().startswith("SELECT"):
                columns = [desc[0] for desc in cur.description]
                results = [dict(zip(columns, row)) for row in cur.fetchall()]
                
                # Cache the result
                if use_cache and cache_key:
                    sync_redis_client.setex(cache_key, cache_expiry, json.dumps(results))

                return results

            # Return last inserted ID for INSERT
            elif query.strip().upper().startswith("INSERT"):
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
