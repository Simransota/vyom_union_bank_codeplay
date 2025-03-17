from fastapi import APIRouter,File, UploadFile
from typing import Dict, Any
import io
from src.gemini_util import generate_cypher_query
from src.query_function import classify_banking_query
from pydantic import BaseModel
from src.utils import execute_query
import uuid
from src.utils import upload_file_to_supabase
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
    
# @router.post('/update_user_photo/')
# async def update_user_photo(user_id: str, photo: io.BytesIO) -> Dict[str, Any]:
#     """
#     Updates the profile photo for the user by uploading it to Supabase
#     and saving the resulting URL
#     """
#     try:
#         # Read file content
#         file_content = await photo.read()
        
#         # Generate a unique filename
#         file_extension = photo.filename.split('.')[-1]
#         file_name = f"{user_id}_{uuid.uuid4()}.{file_extension}"
        
#         # Upload to Supabase storage and get URL
#         photo_url = await upload_file_to_supabase(file_content, file_name, f"{user_id}/profile")
        
#         if not photo_url:
#             return {
#                 "status": "error",
#                 "error": "Failed to upload photo to storage"
#             }
            
#         # Update the user profile with the new photo URL
#         query = """
#         UPDATE Customer
#         SET profile_pic = %s
#         WHERE cust_id = %s;
#         """
#         params = (photo_url, user_id)
#         result = execute_query(query, params)
        
#         if result is not None:
#             return {
#                 "status": "success",
#                 "photo_url": photo_url
#             }
#         return {
#             "status": "error",
#             "error": "Failed to update user profile in database"
#         }
#     except Exception as e:
#         return {
#             "status": "error",
#             "error": str(e)
#         }