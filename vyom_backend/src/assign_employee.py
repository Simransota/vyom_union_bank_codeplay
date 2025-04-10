from src.utils import execute_query_sync as execute_query,QueryRequest
from datetime import datetime
import pytz
ist = pytz.timezone("Asia/Kolkata")
today_ist = datetime.now(ist).date()

def assign_employee(query_id):
    """
    Assign an employee to the query based on the given priority.
    
    Args:
        query_id (str): The ID of the query to assign.
        priority (int): The priority level for assignment.
    """
    # Placeholder for actual assignment logic
    query = QueryRequest(
        query="SELECT * FROM query WHERE query_id = %s", 
        params=(int(query_id),),
        use_cache=False,
        cache_key=None,
        cache_expiry=3600,
        return_id=False
    )
    query_data_list=execute_query(query)
    if query_data_list and len(query_data_list) > 0:
        # Extract the first (and only) item from the list
        query_data = query_data_list[0]
        
        # Extract the required fields
        estimated_time = query_data.get('estimated_time')
        cust_id = query_data.get('cust_id')
        department_name = query_data.get('department_name')
        query_level = query_data.get('query_level')
        language = query_data.get('language')
        start_dt = query_data.get('schedule_time')
        start_dt = ist.localize(datetime(2025, 4, 10, 9, 30))     # tz-aware
        if start_dt:
                end_dt = start_dt + estimated_time
                start_time = start_dt.time()  # datetime.time
                end_time = end_dt.time()      # datetime.time
                query=QueryRequest(
                query="SELECT * FROM get_available_employees_by_time_slot(%s,%s,%s,%s,%s);",
                params=(today_ist,department_name, language,start_time,end_time),
                use_cache=False,
                cache_key=None,
                cache_expiry=3600,
                return_id=False
                )
                available_employees=execute_query(query)
                # print(available_employees)
        else:
            query=QueryRequest(
                query="SELECT * FROM get_employees_by_date_dept_lang(%s,%s,%s);",
                params=(today_ist,department_name, language),
                use_cache=False,
                cache_key=None,
                cache_expiry=3600,
                return_id=False
            )
            available_employees=execute_query(query)
            # print(available_employees)
    else:
        # Handle the case when no query data is found
        print(f"No query found with ID: {query_id}")
        return

