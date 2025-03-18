from typing import Optional
from uuid import UUID
from datetime import datetime, timedelta
from pydantic import BaseModel
from geoalchemy2.types import Geography

class Query(BaseModel):
    query_id: Optional[int] = None
    created: Optional[datetime] = None
    updated: Optional[datetime] = None
    estimated_time: Optional[timedelta] = None
    activity_logs: Optional[dict] = None  # Assuming jsonb is a dict
    subtype: Optional[str] = None
    cust_id: Optional[UUID] = None
    title: Optional[str] = None
    employee: Optional[int] = None
    date_time: Optional[datetime] = None
    department_name: Optional[str] = None
    description: Optional[str] = None
    query_level: Optional[int] = None
    priority_level: Optional[int] = None
    transcript_bkturi: Optional[str] = None
    additional_details: Optional[dict] = None  # Assuming jsonb is a dict
    chat_id: Optional[int] = None
    appointment_id: Optional[int] = None
    status: Optional[str] = None  # Assuming query_status is a string
    location: Optional[Geography] = None  # Assuming Geography is handled by geoalchemy2
    language: Optional[str] = None
    query_sentiment: Optional[str] = None
    categories: Optional[str] = None

from typing import Optional
from uuid import UUID
from datetime import date, datetime
from decimal import Decimal

class Customer(BaseModel):
    cust_id: Optional[UUID] = None
    custname: Optional[str] = None
    email: Optional[str] = None
    phone_no: Optional[str] = None
    device_id: Optional[str] = None
    push_enabled: Optional[bool] = None
    bank_balance: Optional[Decimal] = None
    cred_score: Optional[int] = None
    dob: Optional[date] = None
    branch_id: Optional[int] = None
    join_date: Optional[datetime] = None
    verified_docs: Optional[dict] = None  # Assuming jsonb is a dict
    addition_info: Optional[dict] = None  # Assuming jsonb is a dict
    locations: Optional[dict] = None  # Assuming jsonb is a dict
    profile_pic: Optional[str] = None

from typing import Optional
from uuid import UUID
from datetime import date
from pydantic import BaseModel

class Employee(BaseModel):
    employee_id: Optional[int] = None
    employee_name: Optional[str] = None
    employee_role: Optional[str] = None
    phone_no: Optional[str] = None
    email: Optional[str] = None
    branch_id: Optional[int] = None
    department_name: Optional[str] = None
    join_date: Optional[date] = None
    employee_tier: Optional[str] = None
    dob: Optional[date] = None
    attendance: Optional[dict] = None  # Assuming jsonb is a dict
    lang1: Optional[str] = None
    lang2: Optional[str] = None
    lang3: Optional[str] = None
    employee_uuid: Optional[UUID] = None
    sub_branch: Optional[str] = None

from typing import Optional
from uuid import UUID
from pydantic import BaseModel

class Message(BaseModel):
    chat_id: Optional[int] = None
    message_id: Optional[int] = None
    message_content: Optional[str] = None
    user_send: Optional[bool] = None
    attachment: Optional[str] = None
    to_verify: Optional[bool] = None

class Chat(BaseModel):
    chat_id: Optional[int] = None
    cust_id: Optional[UUID] = None
    employee_id: Optional[int] = None
    query_id: Optional[int] = None
    agent_reply: Optional[bool] = None
    created_at: Optional[datetime] = None

class Document(BaseModel):
    query_id: Optional[int] = None
    document_name: Optional[str] = None
    is_submit: Optional[bool] = None
    doc_url: Optional[str] = None
    # Make models exportable
    __all__ = [
        "Query",
        "Customer",
        "Employee",
        "Message",
        "Chat",
        "Document"
    ]