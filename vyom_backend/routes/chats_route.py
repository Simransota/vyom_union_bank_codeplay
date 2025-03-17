from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from datetime import datetime
from src.utils import execute_query
router = APIRouter(
    prefix="/chats",
    tags=["Chats"]
)

# Get all chats for the current user
@router.get("/", response_model=List[chat_schema.ChatResponse])
def get_all_chats(
    db: Session = Depends(get_db),
    current_user: user_model.User = Depends(get_current_user)
):
    chats = db.query(chat_model.Chat).filter(
        (chat_model.Chat.user1_id == current_user.id) | 
        (chat_model.Chat.user2_id == current_user.id)
    ).all()
    
    return chats

# Get specific chat by ID
@router.get("/{chat_id}", response_model=chat_schema.ChatDetail)
def get_chat(
    chat_id: int,
    db: Session = Depends(get_db),
    current_user: user_model.User = Depends(get_current_user)
):
    chat = db.query(chat_model.Chat).filter(chat_model.Chat.id == chat_id).first()
    
    if not chat:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Chat with id {chat_id} not found"
        )
    
    # Verify user has access to this chat
    if chat.user1_id != current_user.id and chat.user2_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to access this chat"
        )
    
    return chat

# Get all messages for a specific chat
@router.get("/{chat_id}/messages", response_model=List[chat_schema.MessageResponse])
def get_chat_messages(
    chat_id: int,
    db: Session = Depends(get_db),
    current_user: user_model.User = Depends(get_current_user)
):
    chat = db.query(chat_model.Chat).filter(chat_model.Chat.id == chat_id).first()
    
    if not chat:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Chat with id {chat_id} not found"
        )
    
    # Verify user has access to this chat
    if chat.user1_id != current_user.id and chat.user2_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to access this chat"
        )
    
    messages = db.query(chat_model.Message).filter(
        chat_model.Message.chat_id == chat_id
    ).order_by(chat_model.Message.created_at).all()
    
    return messages

# Create a new chat
@router.post("/", status_code=status.HTTP_201_CREATED, response_model=chat_schema.ChatResponse)
def create_chat(
    chat_data: chat_schema.ChatCreate,
    db: Session = Depends(get_db),
    current_user: user_model.User = Depends(get_current_user)
):
    # Check if other user exists
    other_user = db.query(user_model.User).filter(
        user_model.User.id == chat_data.other_user_id
    ).first()
    
    if not other_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with id {chat_data.other_user_id} not found"
        )
    
    # Check if chat already exists between these users
    existing_chat = db.query(chat_model.Chat).filter(
        ((chat_model.Chat.user1_id == current_user.id) & 
         (chat_model.Chat.user2_id == chat_data.other_user_id)) |
        ((chat_model.Chat.user1_id == chat_data.other_user_id) & 
         (chat_model.Chat.user2_id == current_user.id))
    ).first()
    
    if existing_chat:
        return existing_chat
    
    # Create new chat
    new_chat = chat_model.Chat(
        user1_id=current_user.id,
        user2_id=chat_data.other_user_id,
        created_at=datetime.now()
    )
    
    db.add(new_chat)
    db.commit()
    db.refresh(new_chat)
    
    return new_chat

# Add a message to a chat
@router.post("/{chat_id}/messages", status_code=status.HTTP_201_CREATED)
def add_message(
    chat_id: int,
    message_data: str,
    user_send: bool,
):
    # Check if chat exists and user has access
    chat_check_query = """
    SELECT id FROM Chat 
    WHERE id = %s
    """
    chat_result = execute_query(chat_check_query, (chat_id, current_user.id, current_user.id), fetch_one=True)
    
    if not chat_result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Chat with id {chat_id} not found or you don't have access"
        )
    
    content = message_data.get("content")
    emp_send = message_data.get("emp_send", False)
    
    # Insert new message
    insert_query = """
    INSERT INTO Message (chat_id, sender_id, content, created_at, emp_send)
    VALUES (%s, %s, %s, %s, %s)
    RETURNING id, chat_id, sender_id, content, created_at, emp_send
    """
    
    new_message = execute_query(
        insert_query, 
        (chat_id, current_user.id, content, datetime.now(), emp_send),
        fetch_one=True
    )
    
    return new_message

# Delete a chat (optional)
@router.delete("/{chat_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_chat(
    chat_id: int,
):
    # First delete all messages in the chat
    messages_query = """
    DELETE FROM Message
    WHERE chat_id = %s;
    """
    execute_query(messages_query, (chat_id,))
    
    # Then delete the chat itself
    chat_query = """
    DELETE FROM Chat
    WHERE id = %s;
    """
    execute_query(chat_query, (chat_id,))
    
    return {"message": "Chat and all messages deleted successfully"}