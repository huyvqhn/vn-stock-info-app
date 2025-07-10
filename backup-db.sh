#!/bin/bash

# Database backup script for PostgreSQL
set -e

# Configuration
DB_NAME="vnstocks_production"
DB_USER="trader"
DB_HOST="localhost"
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${DATE}.sql"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "🗄️  Starting database backup..."

# Check if running with Kamal
if command -v kamal &> /dev/null && [ -f "deploy.yml" ]; then
    echo "🚀 Using Kamal for backup..."
    kamal app exec pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"
elif [ -f "docker-compose.yml" ]; then
    echo "🐳 Using Docker Compose for backup..."
    docker-compose exec -T db pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"
else
    echo "💻 Using local PostgreSQL for backup..."
    pg_dump -h "$DB_HOST" -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"
fi

# Compress the backup
gzip "$BACKUP_FILE"
BACKUP_FILE_COMPRESSED="${BACKUP_FILE}.gz"

echo "✅ Backup completed successfully!"
echo "📁 Backup file: $BACKUP_FILE_COMPRESSED"
echo "📊 File size: $(du -h "$BACKUP_FILE_COMPRESSED" | cut -f1)"

# Keep only last 7 backups
echo "🧹 Cleaning old backups (keeping last 7)..."
ls -t "$BACKUP_DIR"/backup_*.sql.gz | tail -n +8 | xargs -r rm

echo "🎉 Backup process completed!" 