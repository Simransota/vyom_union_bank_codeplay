import eventlet
eventlet.monkey_patch()  # Add this at the top of your file
from src.utils import execute_query
from datetime import datetime
from src.query_function import process_query_and_save
# query="I lost my bank account debit card and was debitted 12500 by some anonymous number"
# data = {
#     "current_query": "I lost the debit card given and we debited some money",
#     "last_three_queries": [
#         "I lost my bank account debit card and was debitted 12500 by some anonymous number",
#         "What are the operating hrs of the bank",
#         "I want a new debit card"
#     ]
# }

# similarity=process_customer_query(query,"wdugwuygwgbwcfgeygcy")

# print(similarity)
query="""
INSERT INTO query (
    cust_id,
    title,
    description,
    department_name,
    subtype,
    query_level,
    priority_level,
    estimated_time,
    transcript_bkturl,
    status,
    query_sentiment,
    activity_logs,
    additional_details,
    date_time
) VALUES (
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s
)RETURNING query_id;
"""

params=(
    '3e0c98bf-c9b9-4d9b-b244-5d3e4906a386',
    'Sample Query Title',
    'Description of the query',
    'credit',
    'Customer Support',
    1,
    1,
    '1 hour',
    'http://example.com/transcript',
    'Active',
    'Positive',
    '[]',
    '{}',
    datetime.now()
)

result = execute_query(query, params)
print(result)
result =process_query_and_save("I lost my bank account debit card and was debitted 12500 by some anonymous number","3e0c98bf-c9b9-4d9b-b244-5d3e4906a386")