#!/bin/bash

set -e

echo "📦 Installing Python and system dependencies..."

# Установка Python 3.11
echo "🐍 Installing Python 3.11..."
apt update
apt install -y python3.11 python3.11-venv python3.11-dev python3-pip

# Создание виртуального окружения
echo "🔧 Creating Python virtual environment..."
python3.11 -m venv /opt/telegram-bot/venv
source /opt/telegram-bot/venv/bin/activate

# Установка Python пакетов
echo "📚 Installing Python packages..."
pip install --upgrade pip
pip install -r /opt/telegram-bot/requirements.txt

# Установка дополнительных системных пакетов
echo "🛠️ Installing system dependencies..."
apt install -y \
    postgresql-client \
    redis-tools \
    nginx \
    certbot \
    python3-certbot-nginx

echo "✅ Dependencies installed!"