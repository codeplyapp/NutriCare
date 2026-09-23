from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

db_url = settings.sync_database_url

# Fallback mechanism if PostgreSQL is not active locally
engine = None
if db_url.startswith("postgresql"):
    try:
        temp_engine = create_engine(
            db_url,
            pool_pre_ping=True,
            pool_size=10,
            max_overflow=20
        )
        with temp_engine.connect() as conn:
            pass
        engine = temp_engine
    except Exception as e:
        logger.warning(f"Could not connect to PostgreSQL ({e}). Using SQLite fallback: nutricare.db")
        engine = create_engine("sqlite:///./nutricare.db", connect_args={"check_same_thread": False})
else:
    engine = create_engine(
        db_url,
        connect_args={"check_same_thread": False} if "sqlite" in db_url else {}
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
