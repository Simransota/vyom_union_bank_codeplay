from src.query_function import process_query_and_save,generate_query_description
from src.utils import create_customer_neo4j,execute_query_sync,QueryRequest

# latitude: float = 19.2499702
# longitude: float = 72.8593873
# language: str = "Hindi"
# query="I lost my credit card and am in an urgent need of money. Can you please help me with a loan?"
# response = process_query_and_save(query_text=query, cust_id="2b00f215-2a78-4ae7-ade2-e34ce902bce2", latitude=latitude, longitude=longitude, language=language)
# # response = generate_query_description(query)
request=QueryRequest(query="SELECT * FROM get_employees_by_date_dept_lang(%s, %s, %s);", params=['2023-10-29', 'Forex', 'Marathi'],use_cache=False)
request2=QueryRequest(query = """
        SELECT * FROM get_available_employees_by_time_slot(%s, %s, %s, %s, %s);
    """,params=["2023-10-29", "Forex", "Marathi", "12:00:00", "12:30:00"],use_cache=False)
# response = execute_query_sync(request)
response2 = execute_query_sync(request2)
print(response2)
