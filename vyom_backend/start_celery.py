import os
import subprocess
import sys

# Determine the project base directory
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOGS_DIR = os.path.join(BASE_DIR, 'celery_logs')

# Create logs directory if it doesn't exist
if not os.path.exists(LOGS_DIR):
    os.makedirs(LOGS_DIR)
    print(f"Created celery logs directory at {LOGS_DIR}")

def start_worker():
    """Start Celery worker with logs going to celery_logs directory"""
    log_file = os.path.join(LOGS_DIR, 'celery_worker.log')
    cmd = [
        'celery', '-A', 'celery_app', 'worker',
        '--loglevel=INFO',
        f'--logfile={log_file}'
    ]
    print(f"Starting Celery worker: {' '.join(cmd)}")
    subprocess.Popen(cmd)

def start_beat():
    """Start Celery beat scheduler with logs going to celery_logs directory"""
    log_file = os.path.join(LOGS_DIR, 'celery_beat.log')
    schedule_file = os.path.join(LOGS_DIR, 'celerybeat-schedule')
    cmd = [
        'celery', '-A', 'celery_app', 'beat',
        '--loglevel=INFO',
        f'--logfile={log_file}',
        f'--schedule={schedule_file}'
    ]
    print(f"Starting Celery beat scheduler: {' '.join(cmd)}")
    subprocess.Popen(cmd)

def start_flower():
    """Start Flower monitoring tool with logs going to celery_logs directory"""
    log_file = os.path.join(LOGS_DIR, 'flower.log')
    cmd = [
        'celery', '-A', 'celery_app', 'flower',
        '--port=5555',
        f'--log-file-path={log_file}'
    ]
    print(f"Starting Flower monitoring: {' '.join(cmd)}")
    subprocess.Popen(cmd)

if __name__ == "__main__":
    # Parse command line arguments
    if len(sys.argv) > 1:
        if "worker" in sys.argv:
            start_worker()
        if "beat" in sys.argv:
            start_beat()
        if "flower" in sys.argv:
            start_flower()
    else:
        # Start all by default
        start_worker()
        start_beat()
        print("Started Celery worker and beat scheduler")
        print("Run 'python start_celery.py flower' to start the monitoring interface")
