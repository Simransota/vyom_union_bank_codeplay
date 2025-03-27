from src.email_send import send_dynamic_email
import pytz
from src.config import get_pg_connection, release_pg_connection  # Import connection pool functions
from time import sleep
from src.utils import execute_query
from datetime import datetime
from src.utils import is_redis_active
from src.config import redis_client

# Uncomment to send an email dynamically if needed
# send_dynamic_email(
#     subject="Test Email",
#     body="Hello, this is a test.",
#     to_recipients=["recipient@example.com"],
#     cc_recipients=[],
#     bcc_recipients=[]
# )
print(is_redis_active())
# Schedule email time
send_datetime = datetime.strptime("2025-03-09T22:30:00+05:30", "%Y-%m-%dT%H:%M:%S%z")
send_datetime_utc = send_datetime.astimezone(pytz.utc)

print(send_datetime_utc, " Indian time ", send_datetime)

try:
    # Get a connection from the pool
    conn = get_pg_connection()
    if conn:
        try:
            with conn.cursor() as cur:
                
                cur.execute("SELECT 1")  # Test query to verify the connection
                print("PostgreSQL connection active: ✅")
                
        except Exception as inner_e:
            print(f"Error executing query: ❌ {inner_e}")
        finally:
            # Release the connection back to the pool
            release_pg_connection(conn)
    else:
        print("Failed to retrieve a connection from the pool: ❌")
except Exception as e:
    print(f"Error initializing connection pool: ❌ {e}")

query = """
INSERT INTO customer (
    cust_id,
    custname,
    email
) VALUES (
    %s,
    %s,
    %s
);
"""

# Parameters for the query
params = (
    '83ca7765-8890-489f-b046-75ec5902eb51',
    'Yash Asgaonkar',
    'newcustomer@exampe.com'
)

# Data for the new branch
branch_id = 12  # Replace with your desired branch ID
branch_loc_text = 'POINT(73.8567 18.5204)'  # Pune coordinates (replace with your point)
branch_address = "789 New Street"
branch_city = "Pune"
branch_state = "Maharashtra"
branch_manager = 7  # Replace with the branch manager's ID

# Data for the kpi_type
kpi_param_name = "Customer Satisfaction"
kpi_value = 95
kpi_historic_value = [92, 94, 96]
kpi_last_update = datetime.now()

employee_cnt = 18

# Query and parameters
query = """
INSERT INTO branch (
    branch_id,
    branch_loc,
    branch_address,
    branch_city,
    branch_state,
    branch_manager,
    branch_kpi,
    employee_cnt
) VALUES (
    %s,
    ST_GeogFromText(%s),
    %s,
    %s,
    %s,
    %s,
    ARRAY[%s::kpi_type],
    %s
);
"""

# Create a kpi_type object
kpi_record = (
    kpi_param_name,
    kpi_value,
    kpi_historic_value,
    kpi_last_update
)

params = (
    branch_id,
    branch_loc_text,
    branch_address,
    branch_city,
    branch_state,
    branch_manager,
    kpi_record,  # Pass the kpi_record tuple
    employee_cnt
)

# Cache settings (for a SELECT query, not for INSERT)
cache_key = "branch_insertion_result"  # Choose a meaningful cache key
cache_expiry = 3600  # Cache for 1 hour

# Execute the query (INSERT query, so caching is not applicable)
result = execute_query(query, params)

# Example of a SELECT query with caching (if you want to retrieve the inserted branch)
select_query = "SELECT * FROM branch WHERE branch_id = %s"
select_params = (branch_id,)
select_cache_key = f"branch_{branch_id}"  # Unique cache key for the branch
select_result = execute_query(select_query, select_params, use_cache=True, cache_key=select_cache_key, cache_expiry=cache_expiry)

if select_result:
    print(f"Retrieved branch from cache or database: {select_result}")
