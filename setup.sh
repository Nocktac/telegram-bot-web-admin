#!/bin/bash

set -e

echo "🛠️ Setting up Ubuntu 24.04 for Telegram Bot deployment..."

# Обновление системы
echo "🔄 Updating system packages..."
apt update && apt upgrade -y

# Установка базовых пакетов
echo "📦 Installing basic packages..."
apt install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    tree \
    unzip \
    ufw \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Установка Docker
echo "🐳 Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Установка Docker Compose
echo "🐙 Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Добавление пользователя в группу docker
echo "👥 Adding current user to docker group..."
usermod -aG docker $SUDO_USER

# Настройка времени
echo "⏰ Setting up timezone..."
timedatectl set-timezone Europe/Moscow

# Создание директорий
echo "📁 Creating directories..."
mkdir -p /opt/telegram-bot/{data,logs,backups}
mkdir -p /opt/telegram-bot/data/{postgres,redis}

# Настройка прав
chown -R $SUDO_USER:$SUDO_USER /opt/telegram-bot

echo "✅ Setup completed!"
echo ""
echo "🔁 Please logout and login again for group changes to take effect"
echo "📁 Project should be deployed to /opt/telegram-bot"