from psycopg2.pool import SimpleConnectionPool
import redis
import os
from dotenv import load_dotenv
import sys

# Load environment variables at the earliest stage
load_dotenv(verbose=True)

# Check if critical environment variables are loaded
if not os.environ.get("DATABASE_URL") or not os.environ.get("REDIS_URL"):
    print("Error: Critical environment variables not found. Check your .env file.")
    print(f"Current working directory: {os.getcwd()}")
    print(f"DATABASE_URL found: {'Yes' if os.environ.get('DATABASE_URL') else 'No'}")
    print(f"REDIS_URL found: {'Yes' if os.environ.get('REDIS_URL') else 'No'}")

# Initialize pg_pool as None
pg_pool = None

# PostgreSQL Connection Pool
try:
    db_url = os.environ.get("DATABASE_URL")
    print(f"Connecting to database with URL: {db_url}")
    pg_pool = SimpleConnectionPool(
        minconn=5,  # Minimum number of connections in the pool
        maxconn=15,  # Maximum number of connections in the pool
        dsn=db_url
    )
    print("PostgreSQL connection pool initialized successfully")
except Exception as e:
    print(f"Error initializing PostgreSQL connection pool: {e}")

# Function to get a connection from the pool
def get_pg_connection():
    if pg_pool is None:
        print("Error: Connection pool is not initialized")
        return None
    try:
        return pg_pool.getconn()
    except Exception as e:
        print(f"Error getting connection from pool: {e}")
        return None

# Function to return a connection to the pool
def release_pg_connection(conn):
    if pg_pool is None:
        print("Error: Connection pool is not initialized")
        return
    try:
        pg_pool.putconn(conn)
    except Exception as e:
        print(f"Error releasing connection back to pool: {e}")

# Redis Client Initialization
try:
    redis_url = os.environ.get("REDIS_URL")
    print(f"Connecting to Redis with URL: {redis_url}")
    redis_client = redis.from_url(redis_url)
    # Test the connection
    ping_result = redis_client.ping()
    print(f"Redis client initialized successfully, ping result: {ping_result}")
except Exception as e:
    print(f"Error initializing Redis client: {e}")
    redis_client = None
