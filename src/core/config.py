import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    # Telegram Bot
    BOT_TOKEN: str = os.getenv("BOT_TOKEN", "")
    ADMIN_USERNAME: str = os.getenv("ADMIN_USERNAME", "admin")
    ADMIN_PASSWORD: str = os.getenv("ADMIN_PASSWORD", "admin123")
    
    # Database
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./bot.db")
    
    # Redis
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379")
    
    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # External APIs
    WEATHER_API_KEY: str = os.getenv("WEATHER_API_KEY", "")
    
    # Monitoring
    PROMETHEUS_PORT: int = int(os.getenv("PROMETHEUS_PORT", "9090"))

settings = Settings()