from fastapi import APIRouter
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Dict, Any
from src.utils import execute_query
from src.query_function import store_query_as_file,predict_resolution_time
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
    