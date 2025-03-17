# Banking API with Celery and Redis

This project provides a REST API for banking operations using FastAPI and Celery with Redis.

## Directory Structure

- `main.py` - FastAPI application entry point
- `celery_app.py` - Celery worker configuration
- `routes/` - API route modules
- `src/` - Core business logic
- `celery_logs/` - Celery log files and scheduler state
- 

## Starting the Application

1. Start the FastAPI server:

   ```
   uvicorn main:app --reload --port=8000
   ```
2. Start Celery worker and beat scheduler:

   ```
   python start_celery.py
   ```
3. Start Flower monitoring (optional):

   ```
   python start_celery.py flower
   ```

## Celery Logs

All Celery logs are stored in the `celery_logs` directory:

- `celery_worker.log` - Worker process logs
- `celery_beat.log` - Beat scheduler logs
- `flower.log` - Flower monitoring logs
- `celerybeat-schedule` - Beat scheduler persistent state
