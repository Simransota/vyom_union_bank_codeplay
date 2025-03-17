from src.ml_model import predict_priority_score
from src.utils import execute_query
import random
# Example prediction (you might want to remove this after testing with real data)


def get_customer_priority_score(customer_id):
    """
    Retrieve customer data and calculate their priority score
    
    Args:
        customer_id (str): UUID of the customer
        default_asset_value (float): Default asset value to use if not available
        
    Returns:
        float or None: The calculated priority score or None if customer not found
    """
    query = """
    SELECT 
        cust_id,
        bank_balance,
        EXTRACT(YEAR FROM AGE(dob)) AS age,
        EXTRACT(YEAR FROM join_date) AS year_of_joining
    FROM 
        Customer
    WHERE 
        cust_id = %s;
        """
    prompt = (customer_id,)

    result = execute_query(query, prompt)
    
    # Extract values from the result tuple (assuming result has at least one row)
    if result:
        customer_id, bank_balance, age, year_of_joining = result[0]
        
        # Predict priority score using the customer's actual data
        priority_score = predict_priority_score(
            bank_balance=float(bank_balance),
            age=int(age),
            bank_joining_year=int(year_of_joining),
            asset_value=random.randint(20000, 1000000)  # Use a random asset value
        )
        
        return priority_score
    else:
        print(f"No customer found with ID: {customer_id}")
        return None

# Example usage
customer_id = '1fc5f74b-5415-4402-b400-26af4371d865'
score = get_customer_priority_score(customer_id)
if score is not None:
    print(f"Priority score for customer {customer_id}: {score}")