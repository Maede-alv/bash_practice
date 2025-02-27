#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

# Validate required environment variables
if [ -z "$DEST_SERVER" ] || [ -z "$DEST_DIR" ] || [ -z "$SOURCE_FILE" ]; then
    echo "Error: Required environment variables are missing. Please check your .env file."
    exit 1
fi

# Define the backup file name with a timestamp
BACKUP_FILE="/home/vagrant/data/backup_$(date +%F).tar.gz"

# Compress the file before transferring
echo "Compressing $SOURCE_FILE..."
tar -czf $BACKUP_FILE $SOURCE_FILE
if [ $? -ne 0 ]; then
    echo "Error: Failed to compress $SOURCE_FILE."
    exit 1
fi

# Transfer the compressed backup to the destination server
echo "Transferring backup to $DEST_SERVER..."
scp $BACKUP_FILE $DEST_SERVER:$DEST_DIR
if [ $? -ne 0 ]; then
    echo "Error: Failed to transfer backup to $DEST_SERVER."
    exit 1
fi

# Delete backups older than 7 days on the destination server
echo "Cleaning up old backups on $DEST_SERVER..."
ssh $DEST_SERVER "find $DEST_DIR -type f -name 'backup_*.tar.gz' -mtime +7 -delete"
if [ $? -ne 0 ]; then
    echo "Error: Failed to clean up old backups on $DEST_SERVER."
    exit 1
fi

# Print success message
echo "Backup transferred to $DEST_SERVER:$DEST_DIR"
echo "Old backups cleaned."