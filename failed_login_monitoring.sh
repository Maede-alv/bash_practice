#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

LOG_FILE="/var/log/auth.log"

tail -Fn0 $LOG_FILE | grep --line-buffered -E "Failed password|Failed publickey|Invalid user|Connection closed by authenticating user" | while read line ; do
    curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage \
        -d chat_id=$TELEGRAM_CHAT_ID \
        -d text="Failed login attempt detected: $line"
done