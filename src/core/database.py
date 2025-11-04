from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from core.config import settings
import asyncpg

Base = declarative_base()

# Создание асинхронного движка
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=True,
    future=True
)

AsyncSessionLocal = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()

async def init_db():
    """Инициализация базы данных"""
    async with engine.begin() as conn:
        # Создание всех таблиц
        await conn.run_sync(Base.metadata.create_all)
    
    # Создание начальных данных
    async with AsyncSessionLocal() as session:
        # Здесь можно добавить начальные данные
        await session.commit()

# Модели данных
from sqlalchemy import Column, Integer, String, DateTime, Text, Boolean
from datetime import datetime

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, unique=True, index=True)
    username = Column(String, nullable=True)
    first_name = Column(String)
    last_name = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)

class Message(Base):
    __tablename__ = "messages"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    message_text = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)

class Broadcast(Base):
    __tablename__ = "broadcasts"
    
    id = Column(Integer, primary_key=True, index=True)
    message_text = Column(Text)
    successful = Column(Integer, default=0)
    failed = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)