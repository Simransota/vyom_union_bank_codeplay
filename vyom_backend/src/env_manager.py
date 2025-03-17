import os
import sys
from dotenv import load_dotenv

def init_env():
    """Initialize environment variables from .env file"""
    # Get the absolute path of the project root
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    
    # Set the path to the .env file
    dotenv_path = os.path.join(project_root, '.env')
    
    # Check if .env file exists
    if not os.path.exists(dotenv_path):
        print(f"Error: .env file not found at {dotenv_path}")
        return False
    
    # Load the .env file
    load_dotenv(dotenv_path=dotenv_path, verbose=True)
    
    # Verify critical environment variables
    critical_vars = [
        "DATABASE_URL", "REDIS_URL", "CELERY_BROKER_URL", 
        "CELERY_RESULT_BACKEND", "GEMINI_API_KEY", "GROQ_API_KEY"
    ]
    
    missing_vars = [var for var in critical_vars if not os.environ.get(var)]
    
    if missing_vars:
        print(f"Error: Missing critical environment variables: {', '.join(missing_vars)}")
        return False
    
    print(f"Environment variables successfully loaded from {dotenv_path}")
    return True

# Initialize environment when this module is imported
init_success = init_env()
if not init_success:
    print("Warning: Environment initialization incomplete. Application may not function correctly.")
