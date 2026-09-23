import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.database import engine, Base
from app.modules.user_profile.router import router as user_profile_router
from app.modules.nutrition.router import router as nutrition_router
from app.modules.ai_gateway.router import router as ai_gateway_router
from app.modules.consultation.router import router as consultation_router
from app.modules.iot_gateway.router import router as iot_gateway_router
from app.modules.content.router import router as content_router
from app.modules.notification.router import router as notification_router
from app.seed_data import seed_initial_data

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("NutriCare")

# Create database tables automatically
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="REST API NutriCare — Modular Monolith Backend untuk Layanan Kesehatan Gizi & Nutrisi Terpersonalisasi",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url=f"{settings.API_V1_STR}/docs",
    redoc_url=f"{settings.API_V1_STR}/redoc"
)

# CORS configuration for Flutter Web, Mobile, and local testing
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Aggregate Modular Routes
app.include_router(user_profile_router, prefix=settings.API_V1_STR)
app.include_router(nutrition_router, prefix=settings.API_V1_STR)
app.include_router(ai_gateway_router, prefix=settings.API_V1_STR)
app.include_router(consultation_router, prefix=settings.API_V1_STR)
app.include_router(iot_gateway_router, prefix=settings.API_V1_STR)
app.include_router(content_router, prefix=settings.API_V1_STR)
app.include_router(notification_router, prefix=settings.API_V1_STR)

@app.on_event("startup")
def on_startup():
    logger.info("Initializing NutriCare Backend...")
    try:
        seed_initial_data()
        logger.info("Seed data loaded successfully.")
    except Exception as e:
        logger.error(f"Failed to seed initial data: {e}")

@app.get("/")
def root():
    return {
        "app": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "status": "online",
        "docs": f"{settings.API_V1_STR}/docs"
    }

@app.get("/health")
def health_check():
    return {"status": "healthy", "database": "connected"}
