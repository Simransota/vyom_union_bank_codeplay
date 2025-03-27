import eventlet
eventlet.monkey_patch()

# Import environment manager first to ensure env vars are loaded
from src.env_manager import init_success

if not init_success:
    import sys
    print("Failed to initialize environment. Exiting...")
    sys.exit(1)

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from src.utils import is_redis_active
from fastapi.middleware.cors import CORSMiddleware
from src.config import redis_client
from routes import mail_route, ai_route, util_route, query_route, user_route,chats_route
from fastapi.staticfiles import StaticFiles
import os

# Initialize FastAPI app
app = FastAPI(
    title="Banking API",
    description="REST API for banking operations, mail, queries, and AI processing",
    version="1.0.0"
)

# Display configured environment variables for debugging
print(f"\nAPI Configuration:")
print(f"Redis URL: {os.environ.get('REDIS_URL', 'Not set')[:20]}...")
print(f"Database URL: {os.environ.get('DATABASE_URL', 'Not set')[:20]}...")
print(f"Environment ready: {'Yes' if init_success else 'No'}")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to your frontend URL in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files for serving user photos
base_dir = os.path.dirname(os.path.abspath(__file__))
static_dir = os.path.join(base_dir, "static")
os.makedirs(static_dir, exist_ok=True)
app.mount("/static", StaticFiles(directory=static_dir), name="static")

# Include all routers (only including each router once)
app.include_router(mail_route.router)
app.include_router(query_route.router)
app.include_router(ai_route.router) 
app.include_router(util_route.router)
app.include_router(user_route.router)
app.include_router(chats_route.router)

# Global exception handler to ensure all responses are JSON
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"status": "error", "message": str(exc), "details": exc.errors()},
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"status": "error", "message": str(exc)},
    )

# Check Redis connection
print(f"Redis connection active: {is_redis_active()}")

@app.get("/")
async def get_root():
    return {
        "status": "success",
        "data": {
            "message": "Banking API Running",
            "docs": "/docs",
            "redis_status": is_redis_active(),
            "version": "1.0.0"
        }
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)