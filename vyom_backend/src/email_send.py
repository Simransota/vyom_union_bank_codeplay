import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from typing import List
from datetime import datetime
import pytz
from pydantic import BaseModel
import os
from datetime import datetime
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate
from langchain.chains import LLMChain
from dotenv import load_dotenv

import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
class EmailRequest(BaseModel):
    topic: str
    context: str

def send_dynamic_email(subject: str, body: str, to_recipients: List[str], cc_recipients: List[str] = None, bcc_recipients: List[str] = None):
    """
    Sends an email using dynamic SMTP credentials with support for To, CC, and BCC.

    Args:
        smtp_server (str): SMTP server address (e.g., smtp.gmail.com).
        smtp_port (int): SMTP port (587 for TLS, 465 for SSL).
        sender_email (str): Email address to send from.
        sender_password (str): Password or App Password of sender.
        subject (str): Email subject.
        body (str): Email content.
        to_recipients (list): List of main recipient email addresses.
        cc_recipients (list, optional): List of CC recipient email addresses.
        bcc_recipients (list, optional): List of BCC recipient email addresses.

    Returns:
        dict: Status of email sending process.
    """
    try:
        # Setup SMTP Connection using environment variables
        smtp_server = os.environ.get("SMTP_SERVER", "smtp.gmail.com")
        smtp_port = int(os.environ.get("SMTP_PORT", 587))
        smtp_email = os.environ.get("SMTP_EMAIL")
        smtp_password = os.environ.get("SMTP_PASSWORD")
        
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()  # Secure connection
        server.login(smtp_email, smtp_password)  # Use credentials from env vars

        # Prepare email
        msg = MIMEMultipart()
        msg["From"] = smtp_email
        msg["To"] = ", ".join(to_recipients)  # Main recipients
        msg["CC"] = ", ".join(cc_recipients) if cc_recipients else ""  # CC recipients
        msg["Subject"] = subject
        msg.attach(MIMEText(body, "plain"))

        # Combine all recipients (To + CC + BCC)
        all_recipients = to_recipients + (cc_recipients if cc_recipients else []) + (bcc_recipients if bcc_recipients else [])

        # Send email
        server.sendmail(smtp_email, all_recipients, msg.as_string())

        server.quit()
        return {"status": "success", "message": f"Email sent to {len(all_recipients)} recipients."}

    except Exception as e:
        return {"status": "error", "message": str(e)}

def convert_to_utc(user_time: datetime, user_timezone: str):
    local_tz = pytz.timezone(user_timezone)
    localized_time = local_tz.localize(user_time)  # Attach timezone info
    utc_time = localized_time.astimezone(pytz.utc)  # Convert to UTC
    return utc_time

# Load environment variables
load_dotenv()

class EmailRequest(BaseModel):
    topic: str
    context: str

os.environ["GOOGLE_API_KEY"] = os.getenv("GEMINI_API_KEY")

def generate_email(topic: str, context: str) -> str:
    """
    Generates a professional email based on a given topic and context.

    Args:
        topic (str): The email topic or subject.
        context (str): Additional details to include in the email.

    Returns:
        str: Generated email content.
    """
    # ✅ Get current date and time
    current_datetime = datetime.now().strftime("%A, %B %d, %Y - %I:%M %p")

    # ✅ Initialize Gemini LLM
    llm = ChatGoogleGenerativeAI(model="gemini-1.5-pro")

    # ✅ Define Email Prompt Template
    email_prompt = PromptTemplate(
        input_variables=["topic", "context", "datetime"],
        template="""You are an expert email writer. Stick to the topic and draft the email in a professional tone that is suitable for everyone.

        **DO NOT INCLUDE any placeholders like [Your Name], [Recipient Name], or similar.** Ensure that the email is complete.

        Generate a professional email based on the given **topic and context** with the following format:

        **Date:** {datetime}

        **Subject:** (A clear and concise subject line)
        **Greeting:** (Appropriate greeting based on context)
        **Body:** (A well-structured message with a polite and professional tone)
        **Closing:** (A professional closing)

        Topic: `{topic}`
        Context: `{context}`

        **Generated Email:**
        """
    )

    # ✅ Define Chain
    chain = LLMChain(llm=llm, prompt=email_prompt)

    # ✅ Run the chain to generate email
    response = chain.invoke({"topic": topic, "context": context, "datetime": current_datetime})
    return response['text']

# email_config = {
#     "smtp.gmail.com": "smtp.gmail.com",
#     "smtp_port": 587,
#     "sender_email": "yash240904@gmail.com",
#     "sender_password": "xgzg qevh ggck uvgu",  # Use App Password
#     "subject": "Meeting Reminder",
#     "body": "Hello Team,\n\nReminder about our meeting tomorrow at 10 AM.\n\nThanks!",
#     "to_recipients": ["yashalchemist12@gmail.com"],
#     "cc_recipients": ["trackkartahainsale@gmail.com"],
#     "bcc_recipients": ["yasha.ecell24@gmail.com"]
# }
