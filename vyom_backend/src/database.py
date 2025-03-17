"""
Supabase connection module for database operations
"""

import os
from dotenv import load_dotenv
from supabase import create_client, Client

# Load environment variables
load_dotenv()

# Initialize Supabase client
supabase_url = os.environ.get("SUPABASE_URL")
supabase_key = os.environ.get("SUPABASE_KEY")

if not supabase_url or not supabase_key:
    raise ValueError("Missing required environment variables: SUPABASE_URL and SUPABASE_KEY")

supabase_client: Client = create_client(supabase_url, supabase_key)

def get_supabase_client() -> Client:
    """Returns the initialized Supabase client"""
    return supabase_client
