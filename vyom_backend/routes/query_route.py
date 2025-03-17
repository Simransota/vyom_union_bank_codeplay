from fastapi import APIRouter
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Dict, Any
from src.utils import execute_query
from src.query_function import process_query_and_save
router = APIRouter(
    prefix="/query",
    tags=["queries"],
    responses={404: {"description": "Not found"}},
)

QUEUE_NAME = 'query_queue'

class QueryParams(BaseModel):
    priority: int
    name: str

class QueryResponse(BaseModel):
    status: str
    query_id: int = None
    message: str = None

@router.post('/send/', response_model=QueryResponse)
async def send_query(name: str, priority: int) -> Dict[str, Any]:
    """Sends data to postgreSQL and then adds it to redis queue"""
    try:
        query_id = execute_query("INSERT INTO queries (name, priority) VALUES (%s, %s)", (name, priority))
        # redis_client.zadd(QUEUE_NAME, {str(query_id): priority})
        print(f"Query {query_id} added to queue with priority {priority}")
        return {
            "status": "success",
            "query_id": query_id
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }

@router.post('/process/', response_model=QueryResponse)
async def process_query(query: str, user_id: str) -> Dict[str, Any]:
    """Processes a query and saves it to the database"""
    try:
        result = process_query_and_save(query, user_id)
        
        # Check if result contains a valid query_id
        query_id = result.get("query_id")
        if query_id is None:
            # Return error response when no query_id is found
            return {
                "status": "error",
                "message": "Failed to generate query ID"
            }
        
        return {
            "status": "success",
            "query_id": query_id
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }