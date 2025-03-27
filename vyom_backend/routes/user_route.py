from fastapi import APIRouter,File, UploadFile
from typing import Dict, Any
import io
from src.gemini_util import generate_cypher_query
from src.query_function import classify_banking_query
from pydantic import BaseModel
from src.utils import execute_query,upload_file_to_supabase
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

class DeviceIdUpdate(BaseModel):
    user_id: str
    device_id: str

class UserCreate(BaseModel):
    user_id: str

class ProfilePictureUpdate(BaseModel):
    user_id: str
    file: UploadFile = File(...)

@router.post('/update_device-id/')
async def update_device_id(request:DeviceIdUpdate) -> Dict[str, Any]:
        """
        Updates the device id for the user for firebase push notifications
        """
        try:
            query="""
            UPDATE Customer
            SET device_id = %s
            WHERE cust_id = %s;
            """
            params=(request.device_id,request.user_id)
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


@router.post('/update_user_pic/')
async def update_user_pic(user_id: str, file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Updates the user's profile picture by uploading the image to Supabase
    and updating the user's pic_url in the database.
    """
    try:
        # Upload the file to Supabase
        file_content = await file.read()  # Read the file content
        file_extension = file.filename.split('.')[-1]  # Get the file extension
        unique_filename = f"{user_id}_{uuid.uuid4().hex}.{file_extension}"  # Generate a unique filename
        upload_result = upload_file_to_supabase(file_content, unique_filename)

        if upload_result["status"] != "success":
            return {
                "status": "error",
                "message": "Failed to upload the file to Supabase"
            }

        # Get the public URL of the uploaded file
        pic_url = upload_result["url"]

        # Update the user's pic_url in the database
        query = """
        UPDATE Customer
        SET pic_url = %s
        WHERE cust_id = %s;
        """
        params = (pic_url, user_id)
        result = execute_query(query, params)

        if result is not None:
            return {
                "status": "success",
                "pic_url": pic_url
            }
        else:
            return {
                "status": "error",
                "message": "Failed to update the user's pic_url in the database"
            }

    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        }
