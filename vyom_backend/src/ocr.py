import base64
import os
from flask import Flask, request, jsonify
from mistralai import Mistral
from flask_cors import CORS
import google.generativeai as genai
from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes
load_dotenv()

# Configure the Gemini API
genai.configure(api_key='AIzaSyDmM7SLLMiBbRxFQOu_BeGL8x4PP2D-jKw')
model = genai.GenerativeModel("gemini-2.0-flash")

# Get API key from environment variable or use the provided one
MISTRAL_API_KEY = os.environ.get('MISTRAL_API_KEY', 'rS4k5q8LOo4RCGjNyyxrrXuSSK9j5pF6')

@app.route('/process-image', methods=['POST'])
def process_image():
    try:
        # Get the encoded image from the request
        data = request.json
        if not data or 'image' not in data:
            return jsonify({'error': 'No image data provided'}), 400
        
        # Get the base64 encoded image
        encoded_image = data['image']
        
        # Initialize Mistral client
        client = Mistral(api_key=MISTRAL_API_KEY)
        
        # Process the image with Mistral OCR
        ocr_response = client.ocr.process(
            model="mistral-ocr-latest",
            document={
                "type": "image_url",
                "image_url": f"data:image/jpeg;base64,{encoded_image}"
            }
        )
        
        extracted_text = " ".join(page.markdown for page in ocr_response.pages)
        
        # Send extracted text to Gemini for structured JSON output
        gemini_response = model.generate_content(
            f"Extract key details from the following OCR result and return them as a JSON object: {extracted_text}"
        )
        
        structured_data = gemini_response.text
        structured_data = structured_data[8:-4]
        return jsonify({
            'status': 'success',
            'ocr_text': extracted_text,
            'structured_data': structured_data
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=6050, debug=True)
