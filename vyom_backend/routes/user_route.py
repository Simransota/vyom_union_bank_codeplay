from fastapi import APIRouter
from typing import Dict, Any
from src.gemini_util import generate_cypher_query
from src.query_function import classify_banking_query
from pydantic import BaseModel
from fastapi.responses import JSONResponse
from src.utils import execute_query

router = APIRouter(
    prefix="/ai",
    tags=["artificial intelligence"],
    responses={404: {"description": "Not found"}},
)

class AIResponse(BaseModel):
    status: str
    data: Dict[str, Any] = None
    error: str = None

@router.post('/update_device-id/')
async def update_device_id(user_id: str,device_id:str) -> Dict[str, Any]:
        """
        Updates the device id for the user for firebase push notifications
        """
        try:
            query="""
            UPDATE Customer
            SET device_id = %s
            WHERE cust_id = %s;
            """
            params=(device_id,user_id)
            result = execute_query(query,params)
            if result !=None:
                return {
                    "status": "success",
                }
        except Exception as e:
            return {
                "status": "error",
                "error": str(e)
            }

async def create_user(user_id:str):
    """
    Creates a new user in the database
    """
    try:
        query="""
        INSERT INTO Customer (cust_id)
        VALUES (%s)
        """
        params=(user_id,)
        result = execute_query(query,params)
        if result !=None:
            return {
                "status": "success",
            }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        }