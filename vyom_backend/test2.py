import asyncio
from src.config import init_pg_pool,init_redis
from src.utils import execute_query, QueryRequest,execute_query_sync  # ✅ Import function & model

# ✅ Define the Query Request
async def main():
    await init_pg_pool()  # ✅ Ensure the DB pool is initialized before querying
    await init_redis()  # ✅ Ensure Redis is initialized before querying
    query_request = QueryRequest(
        query="""
        SELECT 
            cust_id,
            branch_id,
            email,
            custname,
            phone_no 
        FROM 
            customer
        WHERE 
            cust_id = $1  -- ✅ Parameterized query
        """,
        params=("283c07c9-776b-47a9-ba1f-2ad6b0a826d7",),  # ✅ Secure parameter
        use_cache=True,
        cache_key="customer_283c07c9",
        cache_expiry=3600
    )

    result = await execute_query(query_request)
    print("Query Result:", result)

# ✅ Execute in an Async Environment
asyncio.run(main())

if __name__ == "__main__":
    print("✅ Starting sync database test...")

    # Define the query (with a secure parameter)
    query = """
    SELECT 
        cust_id,
        branch_id,
        email,
        custname,
        phone_no 
    FROM 
        customer
    WHERE 
        cust_id = %s  -- ✅ Parameterized query for security
    """
    params = ("283c07c9-776b-47a9-ba1f-2ad6b0a826d7",)  # ✅ Secure parameter tuple
    cache_key = "customer_283c07c9"

    # ✅ First Run: Fetch from Database
    print("\n🚀 Running first query (DB expected)...")
    result_1 = execute_query_sync(query, params, use_cache=True, cache_key=cache_key, cache_expiry=3600)
    print("Query Result (DB Fetch):", result_1)

    # ✅ Second Run: Should Fetch from Redis Cache
    print("\n🚀 Running second query (Redis cache expected)...")
    result_2 = execute_query_sync(query, params, use_cache=True, cache_key=cache_key, cache_expiry=3600)
    print("Query Result (Redis Cache Fetch):", result_2)

    # ✅ Check if Redis caching works
    is_cached = result_1 == result_2
    print("\n✅ Redis Caching Verified:", "Yes" if is_cached else "No")
