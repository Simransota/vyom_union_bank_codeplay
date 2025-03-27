import asyncpg
import redis
import redis.asyncio as aioredis
import os
import psycopg2
from dotenv import load_dotenv

# Load environment variables at the earliest stage
load_dotenv(verbose=True)

# Ensure critical environment variables are present
if not os.environ.get("DATABASE_URL") or not os.environ.get("REDIS_URL"):
    print("Error: Critical environment variables not found. Check your .env file.")
    print(f"Current working directory: {os.getcwd()}")
    print(f"DATABASE_URL found: {'Yes' if os.environ.get('DATABASE_URL') else 'No'}")
    print(f"REDIS_URL found: {'Yes' if os.environ.get('REDIS_URL') else 'No'}")

# Global variables for async connections
pg_pool = None
redis_client = None

# **ASYNC Function: Initialize PostgreSQL Connection Pool**
async def init_pg_pool():
    global pg_pool
    if pg_pool is None:
        try:
            db_url = os.environ.get("DATABASE_URL")
            print(f"Connecting to PostgreSQL database: {db_url}")
            pg_pool = await asyncpg.create_pool(dsn=db_url, min_size=5, max_size=15,statement_cache_size=0)
            print("✅ PostgreSQL async connection pool initialized successfully")
        except Exception as e:
            print(f"❌ Error initializing PostgreSQL connection pool: {e}")

# **ASYNC Function: Get Connection from Pool**
async def get_pg_connection():
    if pg_pool is None:
        print("❌ Error: PostgreSQL connection pool is not initialized")
        return None
    return await pg_pool.acquire()

# **ASYNC Function: Release Connection Back to Pool**
async def release_pg_connection(conn):
    if pg_pool and conn:
        await pg_pool.release(conn)

# **ASYNC Function: Initialize Redis Client**
async def init_redis():
    """Ensure Redis is initialized once"""
    global redis_client
    if redis_client is None:
        try:
            redis_url = os.environ.get("REDIS_URL")
            print(f"🔍 Connecting to Redis at: {redis_url}")
            redis_client = aioredis.from_url(redis_url, decode_responses=True)
            
            # 🔹 Properly test the connection
            test_redis = await redis_client.ping()
            if test_redis:
                print("✅ Redis connected successfully!")
            else:
                print("❌ Redis ping failed, setting redis_client to None")
                redis_client = None
        except Exception as e:
            print(f"❌ Redis initialization failed: {e}")
            redis_client = None  # Ensure it's reset if failure occurs

# **ASYNC Function: Get Redis Client**
async def get_redis():
    if redis_client is None:
        await init_redis()
    return redis_client

sync_redis_client = redis.Redis.from_url(os.environ.get("REDIS_URL"), decode_responses=True)

def get_db_connection():
    """Creates a new database connection using DB_URL."""
    try:
        db_url = os.getenv("DATABASE_URL")  # ✅ Fetch full URL from env
        if not db_url:
            raise ValueError("❌ DB_URL is not set in environment variables.")

        conn = psycopg2.connect(db_url)  # ✅ Direct connection
        return conn
    except Exception as e:
        print(f"❌ Database connection error: {e}")
        return None