import eventlet
eventlet.monkey_patch()

# Import environment manager first
from src.env_manager import init_success
from src.assign_employee import assign_employee
if not init_success:
    import sys
    print("Failed to initialize environment for Celery. Exiting...")
    sys.exit(1)

import time
import os
from celery import Celery
from src.email_send import send_dynamic_email
# from src.sms_send import send_notification,send_sms
from src.sms_send import send_sms
from typing import List
from src.config import sync_redis_client
from src.utils import execute_query_sync as execute_query

QUEUE_NAME = 'query_queue'

# Get broker and backend URLs from environment
broker_url = os.environ.get('CELERY_BROKER_URL')
backend_url = os.environ.get('CELERY_RESULT_BACKEND')

# Print for debugging
print(f"Celery broker URL: {broker_url[:20]}..." if broker_url else "Celery broker URL not set")
print(f"Celery result backend URL: {backend_url[:20]}..." if backend_url else "Celery result backend URL not set")

# Create logs directory if it doesn't exist
logs_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'celery_logs')
if not os.path.exists(logs_dir):
    os.makedirs(logs_dir)
    print(f"Created celery logs directory at {logs_dir}")

celery_app = Celery(
    'tasks',
    broker=broker_url,
    backend=backend_url,
)
celery_app.conf.update(
    enable_utc=True,
    timezone='Asia/Kolkata',
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    task_track_started=True,
    task_time_limit=30 * 60,  # 30 minutes
    worker_max_tasks_per_child=50,
    task_send_sent_event=True,
    worker_send_task_events=True,
    # Configure logs to store in celery_logs directory
    worker_log_file=os.path.join(logs_dir, 'celery.log'),
    beat_log_file=os.path.join(logs_dir, 'beat.log'),
    beat_schedule_filename=os.path.join(logs_dir, 'celerybeat-schedule'),
)

# Add a task to the QUEUE_NAME queue (query_queue)
def add_query_to_queue(query_id, priority):
    """
    Add a query to the query_queue with the given priority.
    
    Args:
        query_id: The ID of the query to process
        priority: Priority score (higher = more important)
    
    Returns:
        bool: True if added successfully, False otherwise
    """
    try:
        # Add query to the Redis sorted set with priority as score
        sync_redis_client.zadd(QUEUE_NAME, {str(query_id): float(priority)})
        print(f"Added query {query_id} to queue with priority {priority}")
        return True
    except Exception as e:
        print(f"Error adding query to queue: {str(e)}")
        return False

@celery_app.task
def send_mail(subject: str, body: str, to_recipients: List[str] = None, cc_recipients: List[str] = None, bcc_recipients: List[str] = None):
    """Sends an email using the provided parameters."""
    email_config = {
        "subject": subject,
        "body": body,
        "to_recipients": to_recipients or [],
        "cc_recipients": cc_recipients or [],
        "bcc_recipients": bcc_recipients or [],
    }

    response = send_dynamic_email(**email_config)

    return "success" if response.get('status') == 'success' else "error"

@celery_app.task
def apply_aging_to_queue():
    """Increments priority of all queries in Redis every 30 sec."""
    pipe = sync_redis_client.pipeline()
    cursor = 0
    AGING_INCREMENT = 0.2

    while True:
        cursor, queries = sync_redis_client.zscan(QUEUE_NAME, cursor, count=500)
        for query_id, _ in queries:
            pipe.zincrby(QUEUE_NAME, AGING_INCREMENT, query_id)
        pipe.execute()
        if cursor == 0:
            break

# @celery_app.task
# def notification_send(title: str, device_id: str):
#     """Sends an push notification using the provided parameters."""
#     notify_config = {
#         "title": title,
#         "device_id": device_id,
#     }
#     response = send_notification(**notify_config)

#     return "success" if response.get('status') == 'success' else "error"

# @celery_app.task
# def notification_send(title: str, device_id: str):
#     """Sends an push notification using the provided parameters."""
#     notify_config = {
#         "title": title,
#         "device_id": device_id,
#     }
#     response = send_notification(**notify_config)

@celery_app.task
def sms_send(text: str, phone_number: str):
    """Sends an SMS using the provided parameters."""
    response = send_sms(text, phone_number)


@celery_app.task(bind=True)
def process_next_query(self):
    """Process all available queries in the queue by priority."""
    processed_count = 0
    start_time = time.time()
    max_processing_time = 55  # seconds (less than Celery's default 60s timeout)
    
    while True:
        # Check time limit to avoid blocking the worker forever
        if time.time() - start_time > max_processing_time:
            break
            
        # Get highest priority query
        result = sync_redis_client.zpopmax(QUEUE_NAME)
        if not result:
            break  # Queue is empty
            
        query_id, priority = result[0], result[1]
        query_id = query_id.decode('utf-8')
        try:
            # Fetch and process query
            result= assign_employee(query_id, priority)
            if result:
                print(f"Processing Query: {query_id} with priority {priority}")

            processed_count += 1
        except Exception as e:
            # Log error
            print(f"Error processing query {query_id}: {str(e)}")
    return f"Processed {processed_count} queries"

celery_app.conf.beat_schedule = {
    "increase-priority-every-30s": {
        "task": "celery_app.apply_aging_to_queue",  # Fix: change from celery_worker to celery_app
        "schedule": 30.0,  # Every 30 seconds
    },
    "process-next-query": {
        "task": "celery_app.process_next_query",
        "schedule": 60.0,  # Run every minute (adjust as needed)
        "options": {"expires": 55}  # Expire if not started within 55 seconds
    },
}