#!/bin/bash

set -e

echo "🌐 Setting up nginx reverse proxy..."

# Создание конфигурации nginx
cat > /etc/nginx/sites-available/telegram-bot << 'EOF'
server {
    listen 80;
    server_name _;
    
    # Web admin interface
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # API
    location /api {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Статические файлы
    location /static {
        alias /opt/telegram-bot/static;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

# Мониторинг
server {
    listen 9090;
    server_name _;
    
    location / {
        proxy_pass http://127.0.0.1:9090;
        proxy_set_header Host $host;
    }
}
EOF

# Активация конфигурации
ln -sf /etc/nginx/sites-available/telegram-bot /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Проверка конфигурации
nginx -t

# Перезапуск nginx
systemctl enable nginx
systemctl restart nginx

echo "✅ Nginx configured!"