#!/bin/bash

set -e

echo "📦 Creating backup of Telegram Bot..."

# Переменные
PROJECT_DIR="/opt/telegram-bot"
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="telegram-bot-backup-$DATE.tar.gz"

# Создание директории для бэкапов
mkdir -p $BACKUP_DIR

# Остановка сервисов
echo "🛑 Stopping services..."
cd $PROJECT_DIR
docker-compose down

# Создание бэкапа
echo "📁 Creating backup archive..."
tar -czf $BACKUP_DIR/$BACKUP_FILE \
    -C $PROJECT_DIR \
    .env \
    data \
    logs \
    src \
    docker-compose.yml

# Запуск сервисов
echo "🔄 Starting services..."
docker-compose up -d

# Очистка старых бэкапов (храним последние 10)
echo "🧹 Cleaning old backups..."
ls -t $BACKUP_DIR/telegram-bot-backup-*.tar.gz | tail -n +11 | xargs -r rm

echo "✅ Backup created: $BACKUP_DIR/$BACKUP_FILE"
echo "💾 Size: $(du -h $BACKUP_DIR/$BACKUP_FILE | cut -f1)"