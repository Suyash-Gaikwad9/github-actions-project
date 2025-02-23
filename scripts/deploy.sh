#!/bin/bash

# Configuration (using environment variables for flexibility)
APP_DIR="${APP_DIR:-/home/your_username/my_app}"  # Default if env variable not set
APP_NAME="${APP_NAME:-app.py}"
VIRTUAL_ENV_NAME="${VIRTUAL_ENV_NAME:-venv}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
REQUIREMENTS_FILE="${REQUIREMENTS_FILE:-requirements.txt}" # Make requirements file configurable

# Log file
LOG_FILE="$APP_DIR/app.log"

# Function to log messages
log() {
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Stop the old app (more robust)
if [ -f "$APP_DIR/$APP_NAME" ]; then
    log "Stopping old application..."
    pkill -f "$PYTHON_BIN $APP_DIR/$APP_NAME"
    sleep 5 # Give time for the process to stop
fi

# Create the app directory if it doesn't exist
mkdir -p "$APP_DIR"

# Copy the new application files (using rsync for efficient updates)
log "Copying new application files..."

# Ensure the app directory is present in the source location as well
mkdir -p app

rsync -avz app/ "$APP_DIR"

# Create or update the virtual environment
log "Setting up or updating virtual environment..."
if [ ! -d "$APP_DIR/$VIRTUAL_ENV_NAME" ]; then
    $PYTHON_BIN -m venv "$APP_DIR/$VIRTUAL_ENV_NAME"
fi

# Activate the virtual environment
source "$APP_DIR/$VIRTUAL_ENV_NAME/bin/activate"

# Install/Update dependencies (within the virtual environment)
log "Installing/Updating dependencies..."
pip install -r "$APP_DIR/$REQUIREMENTS_FILE" --upgrade

# Deactivate to ensure a clean start
deactivate

# Start the new app (using nohup and redirecting output)
log "Starting new application..."
nohup "$APP_DIR/$VIRTUAL_ENV_NAME/bin/$PYTHON_BIN" "$APP_DIR/$APP_NAME" > "$LOG_FILE" 2>&1 &
log "Application started (see $LOG_FILE for details)."

log "Deployment complete!"
