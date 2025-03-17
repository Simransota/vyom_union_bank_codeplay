from fastapi import FastAPI, UploadFile, File
from fastapi.responses import StreamingResponse
import tts_with_llm  # Importing your existing processing logic
import io
import wave

app = FastAPI()

@app.post("/process_audio/")
async def process_audio(target_lang: str,audio: UploadFile = File(...)):
    """Handles audio input, processes it using AI, and returns generated speech."""
    
    # Save received audio file
    audio_path = "received_audio.wav"
    with open(audio_path, "wb") as f:
        f.write(await audio.read())

    # Convert speech to text
    transcribed_text = tts_with_llm.speech_to_text(audio_path)
    if not transcribed_text:
        return {"error": "Speech-to-text failed"}

    print(f"👂 User said: {transcribed_text}")

    # Process AI response
    ai_response = tts_with_llm.chat_func(transcribed_text)
    print(f"🤖 AI Response: {ai_response}")

    # Translate AI response if needed
    translated_response = tts_with_llm.translate_text(ai_response, "en-IN", target_lang)

    # Convert AI response to speech
    tts_audio = tts_with_llm.text_to_speech(translated_response, target_lang)
    if not tts_audio:
        return {"error": "Text-to-speech failed"}

    # Return AI-generated speech
    return StreamingResponse(io.BytesIO(tts_audio), media_type="audio/wav")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)