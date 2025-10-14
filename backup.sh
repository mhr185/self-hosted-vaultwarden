#!/bin/bash

# Vaultwarden backup script
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR=~/vaultwarden/backups
DATA_DIR=~/vaultwarden/vw-data

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Stop the container to ensure a consistent backup
docker-compose down

# Create a compressed backup
tar -czvf $BACKUP_DIR/vaultwarden_backup_$TIMESTAMP.tar.gz -C $DATA_DIR .

# Restart the container
docker-compose up -d

# Delete backups older than 7 days
find $BACKUP_DIR -type f -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/vaultwarden_backup_$TIMESTAMP.tar.gz"
