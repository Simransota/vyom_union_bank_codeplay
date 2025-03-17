from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from dotenv import load_dotenv
import os
from pinecone import Pinecone, ServerlessSpec
pc = Pinecone(api_key=os.environ.get("PINECONE_API_KEY"))
from langchain_google_genai import ChatGoogleGenerativeAI

load_dotenv()
# Similarity threshold (75%)
SIMILARITY_THRESHOLD = 0.50

def process_query(current_query, last_three_queries):
    if not current_query:
        return {'status': 'error'}
    if not last_three_queries:
        return {
            'status': 'not_enough_info',
        }
    # Prepare data for vectorization
    all_queries = last_three_queries + [current_query]
    
    # Vectorize the queries
    vectorizer = CountVectorizer(stop_words='english')
    try:
        vectors = vectorizer.fit_transform(all_queries).toarray()
    except ValueError:
        return {'status': 'error', 'message': 'Invalid query content'}
    
    # Get the current query vector (last one)
    current_vector = vectors[-1]
    
    # Compare with recent queries
    for i, recent_vector in enumerate(vectors[:-1]):
        similarity = cosine_similarity([recent_vector], [current_vector])[0][0]
        if similarity >= SIMILARITY_THRESHOLD:
            return {
                'status': 'ignored'
            }
    return {
        'status': 'success',
    }


import pickle
import math
import pandas as pd
import os

def predict_priority_score(bank_balance, age, bank_joining_year, asset_value):
    """
    Load the trained model and predict the priority score for a given manual input.

    Parameters:
        bank_balance (float): Bank balance in ₹
        age (int): Age of the customer
        bank_joining_year (int): Year when the customer joined the bank
        asset_value (float): Asset value in ₹

    Returns:
        int: Predicted Priority Score (rounded up)
    """
    
    # Define the absolute path to the model file
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    model_filename = os.path.join(base_dir, "models", "xgboost_priority_model.pkl")
    
    try:
        with open(model_filename, "rb") as file:
            loaded_model = pickle.load(file)
    except FileNotFoundError:
        print(f"Model file not found at: {model_filename}")
        # Fallback to a default priority if model is not available
        return 5  # Return a default medium priority
    except Exception as e:
        print(f"Error loading model: {str(e)}")
        return 5  # Return a default medium priority

    # Create DataFrame from manual input
    input_data = pd.DataFrame([[bank_balance, age, bank_joining_year, asset_value]],
                            columns=X.columns)  # Ensure feature names match
    # Make prediction
    predicted_score = loaded_model.predict(input_data)[0]
    # Round up to the nearest whole number
    return math.ceil(predicted_score)


gemini_api_key="AIzaSyAiTKtMQvBjrTRtHveBfKzL0maKDMqvf0A"
llm = ChatGoogleGenerativeAI(model="gemini-1.5-flash", google_api_key=gemini_api_key)
