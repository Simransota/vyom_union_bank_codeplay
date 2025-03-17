#!/usr/bin/env python
import os
import sys
from dotenv import load_dotenv

def check_env():
    """Check if environment variables are properly loaded"""
    print("\n=== Environment Variables Checker ===\n")
    
    # Get absolute path to the .env file
    script_dir = os.path.dirname(os.path.abspath(__file__))
    env_path = os.path.join(script_dir, '.env')
    
    # Check if .env file exists
    if not os.path.exists(env_path):
        print(f"❌ ERROR: .env file not found at: {env_path}")
        return False
    
    print(f"✅ .env file found at: {env_path}")
    
    # Load environment variables
    print("Loading environment variables...")
    load_dotenv(dotenv_path=env_path, verbose=True)
    
    # Variables to check
    critical_vars = {
        "DATABASE_URL": "Database connection string",
        "REDIS_URL": "Redis connection string",
        "CELERY_BROKER_URL": "Celery broker URL",
        "CELERY_RESULT_BACKEND": "Celery result backend URL",
        "GEMINI_API_KEY": "Google Gemini API key",
        "GROQ_API_KEY": "Groq API key",
        "SMTP_EMAIL": "Email for SMTP",
        "SMTP_PASSWORD": "Password for SMTP",
    }
    
    # Check critical variables
    all_ok = True
    print("\nChecking critical environment variables:")
    
    for var, description in critical_vars.items():
        value = os.environ.get(var)
        if value:
            print(f"✅ {var}: Found ({description})")
            # Print truncated value for sensitive information
            if "KEY" in var or "PASSWORD" in var or "URL" in var:
                print(f"   Value: {value[:10]}...")
            else:
                print(f"   Value: {value}")
        else:
            print(f"❌ {var}: Missing ({description})")
            all_ok = False
    
    print("\nSummary:")
    if all_ok:
        print("✅ All critical environment variables are properly loaded.")
    else:
        print("❌ Some critical environment variables are missing.")
    
    return all_ok

if __name__ == "__main__":
    success = check_env()
    if not success:
        sys.exit(1)
