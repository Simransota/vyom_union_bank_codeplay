from fastapi import APIRouter, UploadFile, File, HTTPException
import io
from typing import Dict, Any
from src.utils import upload_file_to_supabase
from src.gemini_util import transcribe_audio
from src.sms_send import SMSRequest, send_sms
from pydantic import BaseModel

router = APIRouter(
    prefix="/utils",
    tags=["utilities"],
    responses={404: {"description": "Not found"}},
)

@router.post("/upload-file/")
async def upload_file_endpoint(file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    API endpoint to upload a file to Supabase Storage.
    Args:
        file (UploadFile): The uploaded file.
    Returns:
        JSON: Upload result.
    """
    try:
        # Convert uploaded file to BytesIO
        file_content = await file.read()
        file_io = io.BytesIO(file_content)

        # Upload file
        result = upload_file_to_supabase(file_io, file.filename)
        return {
            "status": "success",
            "data": result
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }

@router.post("/transcribe-audio/")
async def transcribe_audio_endpoint(file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    API endpoint to transcribe an audio file using Groq Whisper.
    Args:
        file (UploadFile): The uploaded audio file.
    Returns:
        JSON: Transcription result.
    """
    try:
        # Convert uploaded file to BytesIO
        file_content = await file.read()
        file_io = io.BytesIO(file_content)
        
        # Transcribe audio
        result = transcribe_audio(file_io, file.filename)
        
        # If transcription was successful
        if "status" in result and result["status"] == "success":
            return {
                "status": "success",
                "data": {
                    "filename": result["filename"],
                    "transcription": result["transcription"]
                }
            }
        else:
            # If transcription failed but returned a structured error
            return {
                "status": "error",
                "message": result.get("message", "Unknown transcription error")
            }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }

@router.post("/sms/send/", response_model=Dict[str, Any])
async def send_sms_endpoint(request: SMSRequest) -> Dict[str, Any]:
    """
    Send an SMS using the Twilio service with Gemini AI formatting.
    
    Parameters:
    - text: Content to send
    - recipient_number: The phone number to send the SMS to
    - twilio_sid: (Optional) Twilio SID
    - twilio_auth_token: (Optional) Twilio Auth Token
    - gemini_api_key: (Optional) Gemini API Key for text formatting
    - from_number: (Optional) Sender phone number
    
    Returns:
    - Message SID or error message
    """
    try:
        message_sid = send_sms(
            text=request.text,
            recipient_number=request.recipient_number
        )
        
        return {
            "status": "success",
            "message": "SMS sent successfully",
            "message_sid": message_sid
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send SMS: {str(e)}")
