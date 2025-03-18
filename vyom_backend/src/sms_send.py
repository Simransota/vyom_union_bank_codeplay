import os
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
from pydantic import BaseModel
from twilio.rest import Client
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, messaging
import json
import re

load_dotenv()
class SMSRequest(BaseModel):
    text: str
    recipient_number: str

# Sidharth's no:9969530246

# ✅ Initialize Gemini Model (API key should be passed dynamically)
def generate_sms_format(text: str) -> str:
    """
    Generates a formatted SMS with a title and body using Gemini 1.5 Flash.
    :param api_key: Google API key for authentication
    :param text: The input text to be formatted
    :return: Formatted SMS message
    """
    # Get the API key from environment variable
    api_key = os.environ.get('GOOGLE_API_KEY')
    os.environ['GOOGLE_API_KEY'] = api_key
    
    llm = ChatGoogleGenerativeAI(model="gemini-1.5-flash")
    text_sms = PromptTemplate(
        input_variables=['text'],
        template="""
        You are a helpful assistant that drafts company SMS.
        Given the text, please format it in such a way that it has:
        - **Title**
        - **Body content** (in an alert tone)
        Input text:
        `{text}`
        **Formatted Output:**
        """
    )
    chain = LLMChain(llm=llm, prompt=text_sms)
    result = chain.invoke({"text": text})
    return result['text']  # Return the text content from the result

def send_sms(text, recipient_number):
    """Formats text using Gemini and sends it via Twilio SMS."""
    formatted_sms = generate_sms_format(text=text)
    
    # Use dictionary access for environment variables
    twilio_sid = os.environ.get("TWILIO_SID")
    twilio_auth_token = os.environ.get("TWILIO_AUTH_TOKEN")
    
    client = Client(twilio_sid, twilio_auth_token)
    message = client.messages.create(
        from_="+16315278890",
        to=recipient_number,
        body=formatted_sms,
    )
    return message.sid


def generate_notification_content(text: str) -> dict:
    """
    Generates formatted notification content (title and body) using Gemini 1.5 Flash.
    
    Args:
        text: The input text to be formatted into notification content
        
    Returns:
        dict: Dictionary containing 'title' and 'body' fields for the notification
    """
    # Get the API key from environment variable
    api_key = os.environ.get('GOOGLE_API_KEY')
    os.environ['GOOGLE_API_KEY'] = api_key
    
    llm = ChatGoogleGenerativeAI(model="gemini-1.5-flash")
    notification_prompt = PromptTemplate(
        input_variables=['text'],
        template="""
        You are a notification content specialist.
        Given the text, create a concise notification with:
        - A short, attention-grabbing title (5-8 words maximum)
        - A brief body message (15-25 words maximum)
        
        Input text:
        `{text}`
        
        Output in JSON format:
        {{"title": "Your title here", "body": "Your body text here"}}
        """
    )
    
    chain = LLMChain(llm=llm, prompt=notification_prompt)
    result = chain.invoke({"text": text})
    
    # Parse the JSON response from the LLM
    
    # Extract JSON pattern from the response
    json_pattern = r'\{.*\}'
    json_match = re.search(json_pattern, result['text'], re.DOTALL)
    
    if json_match:
        try:
            notification_content = json.loads(json_match.group())
            return notification_content
        except json.JSONDecodeError:
            # Fallback if JSON parsing fails
            return {"title": "Notification", "body": result['text'][:100]}
    else:
        # Fallback if JSON pattern not found
        return {"title": "Notification", "body": result['text'][:100]}

# Union URL for notification image
# Replace with the actual path to your service account key file
# cred_path = os.path.join(os.path.dirname(__file__), 'google-service.json')
# print(cred_path)
# cred = credentials.Certificate(cred_path)
# firebase_admin.initialize_app(cred)
# img='https://elmmlkdcziylxwjxjkma.supabase.co/storage/v1/object/public/files//unionlogo.jpeg'

# def send_notification(text, device_token, data=None, image_url=img, channel_id="default"):
#     """
#     Generates notification content using AI and sends it as a push notification.
    
#     Args:
#         text: The input text to create notification content from
#         device_token: FCM registration token of the target device
#         data: (Optional) Dictionary containing additional payload data
#         image_url: (Optional) URL of an image to display in the notification
#         channel_id: (Optional) Android notification channel ID
        
#     Returns:
#         Response from FCM send operation
#     """
#     # First generate the notification content
#     content = generate_notification_content(text)
#     title = content.get("title", "Notification")
#     body = content.get("body", text[:100])
    
#     # Then send the push notification
#     notification = messaging.Notification(
#         title=title,
#         body=body,
#         image=image_url
#     )
    
#     android_config = messaging.AndroidConfig(
#         notification=messaging.AndroidNotification(
#             channel_id=channel_id,
#             priority='high',
#             image=image_url
#         )
#     )
    
#     apns_config = messaging.APNSConfig(
#         payload=messaging.APNSPayload(
#             aps=messaging.Aps(
#                 sound='default'
#             )
#         )
#     )
    
#     message = messaging.Message(
#         notification=notification,
#         token=device_token,
#         android=android_config,
#         apns=apns_config,
#         data=data if data else {}
#     )
    
#     try:
#         response = messaging.send(message)
#         print(f"Successfully sent notification: {response}")
#         return response
#     except Exception as e:
#         print(f"Error sending notification: {e}")
#         raise
