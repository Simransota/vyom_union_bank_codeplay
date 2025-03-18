from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Dict, Any
from src.utils import execute_query
from src.query_function import process_query_and_save
from src.utils import redis_client

class QueryRequest(BaseModel):
    query: str
    user_id: str

router = APIRouter(
    prefix="/query",
    tags=["queries"],
    responses={404: {"description": "Not found"}},
)

QUEUE_NAME = 'query_queue'

class QueryParams(BaseModel):
    priority: int
    query_id: int

class QueryResponse(BaseModel):
    status: str
    query_id: int = None
    message: str = None

@router.post('/send/', response_model=QueryResponse)
async def send_query(params: QueryParams) -> Dict[str, Any]:
    """Sends data to postgreSQL and then adds it to redis queue"""
    try:
        redis_client.zadd(QUEUE_NAME, {str(params.query_id): params.priority})
        print(f"Query {params.query_id} added to queue with priority {params.priority}")
        return {
            "status": "success",
            "query_id": params.query_id
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }

@router.post('/process/', response_model=QueryResponse)
async def process_query(request_data: QueryRequest) -> Dict[str, Any]:
    """Processes a query and saves it to the database"""
    try:
        query = request_data.query
        user_id = request_data.user_id
        
        if not query or not user_id:
            return {
                "status": "error",
                "message": "Missing required parameters: query and user_id"
            }
            
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