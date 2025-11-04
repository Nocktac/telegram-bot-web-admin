#!/usr/bin/env python3
import asyncio
import logging
import signal
import sys
from contextlib import asynccontextmanager

from bot.bot import start_bot, stop_bot
from web.api import app as web_app
import uvicorn
from core.config import settings
from core.database import init_db
from core.monitoring import start_monitoring, stop_monitoring

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/bot.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app):
    # Startup
    logger.info("Initializing database...")
    await init_db()
    
    logger.info("Starting monitoring...")
    await start_monitoring()
    
    logger.info("Starting Telegram bot...")
    bot_task = asyncio.create_task(start_bot())
    
    yield
    
    # Shutdown
    logger.info("Shutting down...")
    await stop_bot()
    await stop_monitoring()
    bot_task.cancel()

# Добавляем lifespan к FastAPI приложению
web_app.router.lifespan_context = lifespan

async def main():
    """Основная функция запуска всех сервисов"""
    try:
        # Запуск веб-сервера
        config = uvicorn.Config(
            web_app,
            host="0.0.0.0",
            port=8000,
            log_level="info"
        )
        server = uvicorn.Server(config)
        
        logger.info("Starting web server on http://0.0.0.0:8000")
        await server.serve()
        
    except Exception as e:
        logger.error(f"Failed to start application: {e}")
        sys.exit(1)

def signal_handler(signum, frame):
    """Обработчик сигналов для graceful shutdown"""
    logger.info(f"Received signal {signum}, shutting down...")
    sys.exit(0)

if __name__ == "__main__":
    # Регистрация обработчиков сигналов
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Запуск приложения
    asyncio.run(main())