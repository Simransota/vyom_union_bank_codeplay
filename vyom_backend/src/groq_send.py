from fastapi import FastAPI, WebSocket
import httpx
from dotenv import load_dotenv
import os
load_dotenv()
async def send_to_groq(audio_data: bytes, language: str = "en", prompt: str = "") -> str:
    """
    Sends the audio batch to Groq's Whisper API for transcription,
    including the language and prompt parameters.
    """
    groq_api_url = os.environ.get("GROQ_API_KEY")   # Update with your actual endpoint.
    headers = {
        f'Authorization": "Bearer {os.environ.get("GROQ_2_KEY")}',  # Update with your Groq API key.
    }
    
    # Prepare the files and additional form fields.
    files = {
        "file": ("audio.wav", audio_data, "audio/wav"),
    }
    # Additional parameters are sent via the "data" parameter.
    data = {
        "language": language,
        "prompt": prompt
    }
    
    async with httpx.AsyncClient() as client:
        response = await client.post(groq_api_url, headers=headers, files=files, data=data)
        response.raise_for_status()
        result = response.json()
        # Expecting the response JSON to include a "transcript" field.
        return result.get("transcript", "")
