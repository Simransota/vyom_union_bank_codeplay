from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from datetime import datetime
from src.utils import execute_query
router = APIRouter(
    prefix="/chats",
    tags=["Chats"]
)

# Get specific chat by ID
@router.get("/all_chats/{user_id}")
def get_chat(
    user_id:str,
):
    query="""
    SELECT 
        cust_id,
        employee_id,
        query_id,
        agent_reply,
        created_at  
    FROM 
        chat
    WHERE 
        (cust_id = %s)
    """
    params=(user_id,)
    chat = execute_query(query,params)
    return chat

# Get all messages for a specific chat
@router.get("/{chat_id}/messages")
def get_chat_messages(
    chat_id: int,
):
    # Check if chat exists
    chat_query = """
    SELECT id FROM chat 
    WHERE id = %s
    """
    chat = execute_query(chat_query, (chat_id,))
    
    if not chat:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Chat with id {chat_id} not found"
        )
    
    # Get all messages for the chat
    messages_query = """
    SELECT 
        message_id,
        chat_id,
        message_content,
        user_send,
        created_at
    FROM 
        message
    WHERE 
        chat_id = %s
    ORDER BY 
        created_at
    """
    
    messages = execute_query(messages_query, (chat_id,))
    
    return messages

# Create a new chat
@router.post("/")
def create_chat(
    cust_id: str,
    employee_id: str,
    query_id: str
):
    # Create new chat without checking for existing ones
    insert_query = """
    INSERT INTO chat (
        cust_id,
        employee_id,
        query_id,
        created_at
    ) VALUES (
        %s, 
        %s, 
        %s,
        NOW()
    )
    RETURNING chat_id, employee_id, query_id, created_at
    """
    new_chat = execute_query(
        insert_query, 
        (cust_id, employee_id, query_id),
    )
    
    return new_chat

# Add a message to a chat
@router.post("/{chat_id}/messages", status_code=status.HTTP_201_CREATED)
def add_message(
    chat_id: int,
    message_data: dict,
):
    # Check if chat exists and user has access
    chat_check_query = """
    SELECT chat_id FROM chat 
    WHERE chat_id = %s
    """
    chat_result = execute_query(chat_check_query, (chat_id,))
    
    if not chat_result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Chat with id {chat_id} not found or you don't have access"
        )
    
    content = message_data.get("content")
    user_send = message_data.get("user_send")
    
    # Insert new message
    insert_query = """
        INSERT INTO message (
        chat_id,
        message_content,
        user_send
        ) VALUES (
        %s, 
        %s, 
        %s  
        )
        RETURNING chat_id, message_id
    """
    
    new_message = execute_query(
        insert_query, 
        (chat_id, content, user_send),
    )
    
    return new_message

# Delete a chat (optional)
@router.delete("/{chat_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_chat(
    chat_id: int,
):
    # First delete all messages in the chat
    messages_query = """
    DELETE FROM message
    WHERE chat_id = %s;
    """
    execute_query(messages_query, (chat_id,))
    
    # Then delete the chat itself
    chat_query = """
    DELETE FROM chat
    WHERE id = %s;
    """
    execute_query(chat_query, (chat_id,))
    
    return {"message": "Chat and all messages deleted successfully"}