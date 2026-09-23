import uuid
from datetime import datetime
from sqlalchemy import (
    Column, String, Integer, Float, Boolean, Text, DateTime, ForeignKey, Table
)
from sqlalchemy.orm import relationship
from app.core.database import Base

def generate_uuid():
    return str(uuid.uuid4())

# Many-to-Many association for Saved Articles
saved_articles_table = Table(
    "saved_articles",
    Base.metadata,
    Column("user_id", String, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
    Column("article_id", String, ForeignKey("articles.id", ondelete="CASCADE"), primary_key=True),
    Column("saved_at", DateTime, default=datetime.utcnow)
)

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    phone = Column(String(50), nullable=True)
    hashed_password = Column(String(255), nullable=False)
    role = Column(String(50), default="user")  # user, dokter_gizi, admin
    pdp_consent_given = Column(Boolean, default=False)  # Kepatuhan UU PDP
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    profile = relationship("NutritionProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    meal_logs = relationship("MealLog", back_populates="user", cascade="all, delete-orphan")
    consultations = relationship("Consultation", back_populates="user", cascade="all, delete-orphan")
    chat_messages = relationship("ChatMessage", back_populates="user", cascade="all, delete-orphan")
    device_pairings = relationship("DevicePairing", back_populates="user", cascade="all, delete-orphan")
    saved_articles = relationship("Article", secondary=saved_articles_table, back_populates="saved_by_users")
    quiz_attempts = relationship("QuizAttempt", back_populates="user", cascade="all, delete-orphan")
    certificates = relationship("Certificate", back_populates="user", cascade="all, delete-orphan")
    progress = relationship("UserProgress", back_populates="user", uselist=False, cascade="all, delete-orphan")

class NutritionProfile(Base):
    __tablename__ = "nutrition_profiles"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    age = Column(Integer, nullable=False)
    gender = Column(String(20), nullable=False)  # pria, wanita
    height_cm = Column(Float, nullable=False)
    weight_kg = Column(Float, nullable=False)
    activity_level = Column(String(50), nullable=False)  # sedentary, light, moderate, heavy
    special_condition = Column(String(255), nullable=True)  # diabetes, hipertensi, dll
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="profile")
    nutrition_target = relationship("NutritionTarget", back_populates="profile", uselist=False, cascade="all, delete-orphan")

class NutritionTarget(Base):
    __tablename__ = "nutrition_targets"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    profile_id = Column(String, ForeignKey("nutrition_profiles.id", ondelete="CASCADE"), unique=True, nullable=False)
    calorie_target = Column(Float, nullable=False)
    protein_g = Column(Float, nullable=False)
    carb_g = Column(Float, nullable=False)
    fat_g = Column(Float, nullable=False)
    water_ml = Column(Float, nullable=False)

    profile = relationship("NutritionProfile", back_populates="nutrition_target")

class MealLog(Base):
    __tablename__ = "meal_logs"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    item_name = Column(String(255), nullable=False)
    meal_type = Column(String(50), default="snack")  # sarapan, makan_siang, makan_malam, snack, minuman
    calorie = Column(Float, nullable=False)
    protein_g = Column(Float, default=0.0)
    carb_g = Column(Float, default=0.0)
    fat_g = Column(Float, default=0.0)
    sugar_g = Column(Float, default=0.0)
    water_ml = Column(Float, default=0.0)
    logged_at = Column(DateTime, default=datetime.utcnow, index=True)

    user = relationship("User", back_populates="meal_logs")

class Doctor(Base):
    __tablename__ = "doctors"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    name = Column(String(255), nullable=False)
    specialty = Column(String(255), nullable=False)
    affiliation = Column(String(255), nullable=False)  # Puskesmas / RSU / Klinik
    rating = Column(Float, default=5.0)
    photo_url = Column(String(500), nullable=True)
    fee = Column(Float, default=0.0)  # Biaya konsultasi
    available_days = Column(String(255), default="Senin - Jumat, 09:00 - 17:00")
    is_available = Column(Boolean, default=True)

    consultations = relationship("Consultation", back_populates="doctor")

class Consultation(Base):
    __tablename__ = "consultations"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    doctor_id = Column(String, ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False)
    scheduled_at = Column(DateTime, nullable=False)
    status = Column(String(50), default="confirmed")  # confirmed, ongoing, completed, cancelled
    call_token = Column(String(500), nullable=True)
    consultation_type = Column(String(50), default="chat")  # chat, video_call
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="consultations")
    doctor = relationship("Doctor", back_populates="consultations")

class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    sender = Column(String(50), nullable=False)  # user, nutri_mate, doctor
    message = Column(Text, nullable=False)
    is_escalated = Column(Boolean, default=False)
    sent_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="chat_messages")

class DevicePairing(Base):
    __tablename__ = "device_pairings"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    device_id = Column(String(255), nullable=False)
    device_type = Column(String(100), default="smartwatch")  # smartwatch, band, ble_sensor
    device_name = Column(String(255), default="NutriCare Smartwatch")
    is_connected = Column(Boolean, default=True)
    battery_pct = Column(Integer, default=85)
    last_sync_at = Column(DateTime, default=datetime.utcnow)
    paired_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="device_pairings")

class Article(Base):
    __tablename__ = "articles"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    title = Column(String(255), nullable=False)
    category = Column(String(100), nullable=False)  # Gizi Harian, Diet Sehat, Hidrasi, Penyakit Kronis
    summary = Column(Text, nullable=True)
    content = Column(Text, nullable=False)
    content_url = Column(String(500), nullable=True)
    image_url = Column(String(500), nullable=True)
    read_time_minutes = Column(Integer, default=5)
    created_at = Column(DateTime, default=datetime.utcnow)

    saved_by_users = relationship("User", secondary=saved_articles_table, back_populates="saved_articles")

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String, nullable=True, index=True)
    action = Column(String(100), nullable=False)
    resource_accessed = Column(String(255), nullable=False)
    ip_address = Column(String(50), default="127.0.0.1")
    details = Column(Text, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)

# ----------------- FASE 2: KURIKULUM GIZI & GAMIFIKASI PRIVAT (ADAPTASI SIGAP) -----------------

class StudyModule(Base):
    __tablename__ = "study_modules"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    title = Column(String(255), nullable=False)
    category = Column(String(100), nullable=False)  # Dasar Gizi, Diabetes, Hipertensi, Ibu & Anak, Olahraga
    level_order = Column(Integer, default=1)
    description = Column(Text, nullable=False)
    content = Column(Text, nullable=False)  # Lengkap / Markdown
    icon_name = Column(String(50), default="menu_book")
    estimated_minutes = Column(Integer, default=10)
    created_at = Column(DateTime, default=datetime.utcnow)

    flashcards = relationship("Flashcard", back_populates="module", cascade="all, delete-orphan")
    quiz_questions = relationship("QuizQuestion", back_populates="module", cascade="all, delete-orphan")
    quiz_attempts = relationship("QuizAttempt", back_populates="module", cascade="all, delete-orphan")

class Flashcard(Base):
    __tablename__ = "flashcards"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    module_id = Column(String, ForeignKey("study_modules.id", ondelete="CASCADE"), nullable=False, index=True)
    term = Column(String(255), nullable=False)
    definition = Column(Text, nullable=False)
    practical_tip = Column(Text, nullable=True)

    module = relationship("StudyModule", back_populates="flashcards")

class QuizQuestion(Base):
    __tablename__ = "quiz_questions"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    module_id = Column(String, ForeignKey("study_modules.id", ondelete="CASCADE"), nullable=True, index=True)  # Nullable for final exam
    question = Column(Text, nullable=False)
    options_json = Column(Text, nullable=False)  # JSON array of string options
    correct_index = Column(Integer, nullable=False)
    explanation = Column(Text, nullable=False)
    is_case_study = Column(Boolean, default=False)
    is_exam = Column(Boolean, default=False)

    module = relationship("StudyModule", back_populates="quiz_questions")

class QuizAttempt(Base):
    __tablename__ = "quiz_attempts"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    module_id = Column(String, ForeignKey("study_modules.id", ondelete="CASCADE"), nullable=True, index=True)
    score = Column(Float, nullable=False)
    total_questions = Column(Integer, default=5)
    correct_answers = Column(Integer, default=5)
    passed = Column(Boolean, default=True)
    is_exam = Column(Boolean, default=False)
    attempted_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="quiz_attempts")
    module = relationship("StudyModule", back_populates="quiz_attempts")

class Certificate(Base):
    __tablename__ = "certificates"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    certificate_number = Column(String(100), unique=True, nullable=False)
    title = Column(String(255), default="Sertifikat Kompetensi Gizi Seimbang NutriCare")
    recipient_name = Column(String(255), nullable=False)
    issued_at = Column(DateTime, default=datetime.utcnow)
    verification_code = Column(String(100), nullable=False)

    user = relationship("User", back_populates="certificates")

class UserProgress(Base):
    __tablename__ = "user_progress"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    streak_days = Column(Integer, default=1)
    last_activity_date = Column(DateTime, default=datetime.utcnow)
    total_points = Column(Integer, default=150)
    current_level = Column(String(50), default="Nutri Novice")  # Nutri Novice, Gizi Seimbang Pro, Master Nutrisi
    unlocked_badges_json = Column(Text, default='["pionir_gizi"]')  # JSON list of badge IDs
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="progress")

