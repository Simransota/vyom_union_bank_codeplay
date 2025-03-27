from fastapi import APIRouter
from typing import Dict, Any
from src.gemini_util import generate_cypher_query
from src.query_function import classify_banking_query
from pydantic import BaseModel
from fastapi.responses import JSONResponse

router = APIRouter(
    prefix="/ai",
    tags=["artificial intelligence"],
    responses={404: {"description": "Not found"}},
)

class AIResponse(BaseModel):
    status: str
    data: Dict[str, Any] = None
    error: str = None

@router.post('/generate-cypher/')
async def create_cypher_query(query: str) -> Dict[str, Any]:
    """Generate a Cypher query from natural language input"""
    try:
        cypher_query = generate_cypher_query(query)
        return {
            "status": "success",
            "data": {"cypher_query": cypher_query}
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        }

@router.post('/classify-bank-query/')
async def classify_bank_query_endpoint(query: str) -> Dict[str, Any]:
    """Classify a banking query into appropriate categories"""
    try:
        classification = classify_banking_query(query)
        return {
            "status": "success",
            "data": {"classification": classification}
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        }

@router.post("/analyze-sentiment/")
async def analyze_sentiment_endpoint(text: str):
    """
    Analyze the sentiment of the given text.
    """
    try:
        result = analyze_sentiment(text)
        return JSONResponse(content=result)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)
