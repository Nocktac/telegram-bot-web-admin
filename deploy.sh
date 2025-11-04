#!/bin/bash

set -e

echo "🚀 Starting deployment of Telegram Bot with Web Admin..."

# Проверка прав root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root or with sudo"
    exit 1
fi

# Переменные
PROJECT_DIR="/opt/telegram-bot"
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "📁 Creating project directory..."
mkdir -p $PROJECT_DIR
mkdir -p $BACKUP_DIR

# Бэкап существующей установки
if [ -d "$PROJECT_DIR" ] && [ "$(ls -A $PROJECT_DIR)" ]; then
    echo "📦 Creating backup..."
    tar -czf "$BACKUP_DIR/telegram-bot-backup-$DATE.tar.gz" -C $PROJECT_DIR .
fi

# Копирование файлов проекта
echo "📄 Copying project files..."
cp -r ./* $PROJECT_DIR/
chmod +x $PROJECT_DIR/*.sh
chmod +x $PROJECT_DIR/scripts/*.sh

# Настройка прав
chown -R $SUDO_USER:$SUDO_USER $PROJECT_DIR

# Запуск установки зависимостей
echo "📦 Installing dependencies..."
cd $PROJECT_DIR
./scripts/install_dependencies.sh

# Настройка переменных окружения
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo "⚙️ Creating .env file from template..."
    cp .env.example .env
    echo "📝 Please edit $PROJECT_DIR/.env with your configuration"
fi

# Настройка firewall
echo "🔥 Configuring firewall..."
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8000/tcp
ufw allow 8080/tcp
ufw --force enable

# Запуск сервисов
echo "🐳 Starting Docker containers..."
docker-compose down
docker-compose up -d

# Настройка nginx
echo "🌐 Configuring nginx..."
./scripts/setup_nginx.sh

# Настройка SSL (опционально)
read -p "🔐 Do you want to setup SSL with Let's Encrypt? (y/n): " setup_ssl
if [ "$setup_ssl" = "y" ]; then
    ./scripts/setup_ssl.sh
fi

# Создание systemd service
echo "🎯 Creating systemd service..."
cat > /etc/systemd/system/telegram-bot.service << EOF
[Unit]
Description=Telegram Bot with Web Admin
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable telegram-bot.service

echo "✅ Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "1. Edit $PROJECT_DIR/.env with your configuration"
echo "2. Run: sudo systemctl start telegram-bot"
echo "3. Check logs: docker-compose logs -f"
echo ""
echo "🌐 Web Admin will be available at: http://your-server-ip:8080"
echo "🤖 Bot token must be set in .env file"