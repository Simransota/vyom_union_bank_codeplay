from fastapi import APIRouter, HTTPException
from pydantic import BaseModel,Field
from typing import List, Dict, Any,Optional
from datetime import datetime
import pytz
from celery.result import AsyncResult
# from celery_app import send_mail, send_notification, send_sms
from celery_app import send_mail,send_sms
from src.email_send import generate_email, EmailRequest
# from src.sms_send import send_notification

router = APIRouter(
    prefix="/mail",
    tags=["email"],
    responses={404: {"description": "Not found"}},
)

class SMSParams(BaseModel):
    phone_number: str
    message: str
    send_datetime: Optional[str]  =Field(default="2025-03-27T20:26:00+0530" , description="The time at which the email should be sent in %Y-%m-%dT%H:%M:%S%z")

class NotificationParams(BaseModel):
    device_id: str
    title: str
    message: str
    send_datetime: Optional[str]  =Field(default="2025-03-27T20:26:00+0530" , description="The time at which the email should be sent in %Y-%m-%dT%H:%M:%S%z")


class MailParams(BaseModel):
    subject: str
    body: str
    to_recipients: List[str]
    cc_recipients: List[str] = []
    bcc_recipients: List[str] = []
    send_datetime: Optional[str]  =Field(default="2025-03-27T20:26:00+0530" , description="The time at which the email should be sent in %Y-%m-%dT%H:%M:%S%z")

class MailResponse(BaseModel):
    status: str = "success"
    task_id: str
    scheduled_time: str = None
    message: str = None

class NotificationParams(BaseModel):
    device_id: str
    title: str

@router.post('/scheduled_mail/', response_model=MailResponse)
async def create_task(params: MailParams) -> Dict[str, Any]:
    """Schedule an email task at a given IST time."""
    try:
        datetime_formatted = datetime.strptime(params.send_datetime, "%Y-%m-%dT%H:%M:%S%z")
        send_datetime_utc = datetime_formatted.astimezone(pytz.utc)
        
        # Check if the scheduled time is in the future
        if send_datetime_utc <= datetime.now(pytz.utc):
            return {
                "status": "error",
                "message": "Scheduled time must be in the future",
                "task_id": None
            }

        task = send_mail.apply_async(
            args=[params.subject, params.body, params.to_recipients, params.cc_recipients, params.bcc_recipients],
            eta=send_datetime_utc
        )
        
        return {
            "status": "success",
            "task_id": task.id,
            "scheduled_time": send_datetime_utc.isoformat()
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "task_id": None
        }

@router.post('/send_mail/', response_model=MailResponse)
async def send_mail_now(params: MailParams) -> Dict[str, Any]:
    """Send an email immediately."""
    try:
        task = send_mail.delay(params.subject, params.body, params.to_recipients, params.cc_recipients, params.bcc_recipients)
        return {
            "status": "success",
            "task_id": task.id
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "task_id": None
        }

@router.get('/task/{task_id}')
async def get_task_status(task_id: str) -> Dict[str, Any]:
    """Check Celery task status"""
    try:
        task_result = AsyncResult(task_id)
        return {
            "status": "success",
            "task_id": task_id, 
            "task_status": task_result.status,
            "result": task_result.result if task_result.ready() else None
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "task_id": task_id
        }

@router.post("/generate-email/")
async def generate_email_endpoint(request: EmailRequest):
    """
    API endpoint to generate a professional email.

    Args:
        request (EmailRequest): Request body containing API key, topic, and context.

    Returns:
        JSON: Generated email.
    """
    try:
        email_content = generate_email(request.api_key, request.topic, request.context)
        return {"status": "success", "email": email_content}
    except Exception as e:
        return {"status": "error", "message": str(e)}


@router.post('/send_sms/', response_model=MailResponse)
async def send_sms_now(params: SMSParams) -> Dict[str, Any]:
    """Send an SMS immediately."""
    try:
        task = send_sms.delay(params.phone_number, params.message)
        return {
            "status": "success",
            "task_id": task.id
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "task_id": None
        }

@router.post('/scheduled_sms/', response_model=MailResponse)
async def schedule_sms(params: SMSParams) -> Dict[str, Any]:
    """Schedule an SMS task at a given time."""
    try:
        if params.send_datetime:
            datetime_formatted = datetime.strptime(params.send_datetime, "%Y-%m-%dT%H:%M:%S%z")
            send_datetime_utc = datetime_formatted.astimezone(pytz.utc)
            
            # Check if the scheduled time is in the future
            if send_datetime_utc <= datetime.now(pytz.utc):
                return {
                    "status": "error",
                    "message": "Scheduled time must be in the future",
                    "task_id": None
                }

            task = send_sms.apply_async(
                args=[params.phone_number, params.message],
                eta=send_datetime_utc
            )
            
            return {
                "status": "success",
                "task_id": task.id,
                "scheduled_time": send_datetime_utc.isoformat()
            }
        else:
            return {
                "status": "error",
                "message": "send_datetime is required for scheduling",
                "task_id": None
            }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "task_id": None
        }

# @router.post('/send_notification/', response_model=MailResponse)
# async def send_notification_now(params: NotificationParams) -> Dict[str, Any]:
#     """Send a notification immediately."""
#     try:
#         task = send_notification.delay(params.device_id, params.title, params.message)
#         return {
#             "status": "success",
#             "task_id": task.id
#         }
#     except Exception as e:
#         return {
#             "status": "error",
#             "message": str(e),
#             "task_id": None
#         }

# @router.post('/scheduled_notification/', response_model=MailResponse)
# async def schedule_notification(params: NotificationParams) -> Dict[str, Any]:
#     """Schedule a notification task at a given time."""
#     try:
#         if params.send_datetime:
#             datetime_formatted = datetime.strptime(params.send_datetime, "%Y-%m-%dT%H:%M:%S%z")
#             send_datetime_utc = datetime_formatted.astimezone(pytz.utc)
            
#             # Check if the scheduled time is in the future
#             if send_datetime_utc <= datetime.now(pytz.utc):
#                 return {
#                     "status": "error",
#                     "message": "Scheduled time must be in the future",
#                     "task_id": None
#                 }

#             task = send_notification.apply_async(
#                 args=[params.device_id, params.title, params.message],
#                 eta=send_datetime_utc
#             )
            
#             return {
#                 "status": "success",
#                 "task_id": task.id,
#                 "scheduled_time": send_datetime_utc.isoformat()
#             }
#         else:
#             return {
#                 "status": "error",
#                 "message": "send_datetime is required for scheduling",
#                 "task_id": None
#             }
#     except Exception as e:
#         return {
#             "status": "error",
#             "message": str(e),
#             "task_id": None
#         }