import os
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
from pydantic import BaseModel
from twilio.rest import Client
from dotenv import load_dotenv
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
