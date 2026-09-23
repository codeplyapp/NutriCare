from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class ArticleResponse(BaseModel):
    id: str
    title: str
    category: str
    summary: Optional[str]
    content: str
    content_url: Optional[str]
    image_url: Optional[str]
    read_time_minutes: int
    is_bookmarked: bool = False
    created_at: datetime

class BookmarkToggleResponse(BaseModel):
    article_id: str
    is_bookmarked: bool
    message: str

# ----------------- KURIKULUM & GAMIFIKASI SCHEMAS -----------------

class FlashcardResponse(BaseModel):
    id: str
    module_id: str
    term: str
    definition: str
    practical_tip: Optional[str] = None

class QuizQuestionResponse(BaseModel):
    id: str
    module_id: Optional[str] = None
    question: str
    options: List[str]
    correct_index: int
    explanation: str
    is_case_study: bool = False
    is_exam: bool = False

class StudyModuleResponse(BaseModel):
    id: str
    title: str
    category: str
    level_order: int
    description: str
    content: str
    icon_name: str
    estimated_minutes: int
    is_completed: bool = False
    best_score: Optional[float] = None
    flashcards_count: int = 0
    quiz_count: int = 0

class QuizSubmitRequest(BaseModel):
    answers: List[int]  # List of chosen option indexes matching question order

class QuizSubmitResponse(BaseModel):
    module_id: Optional[str] = None
    score: float
    total_questions: int
    correct_answers: int
    passed: bool
    points_earned: int
    streak_updated: bool
    new_badge: Optional[str] = None
    explanation_review: List[dict] = []

class CertificateResponse(BaseModel):
    id: str
    certificate_number: str
    title: str
    recipient_name: str
    issued_at: datetime
    verification_code: str

class BadgeInfo(BaseModel):
    id: str
    title: str
    description: str
    icon_name: str
    unlocked_at: Optional[str] = None
    is_unlocked: bool = False

class UserProgressResponse(BaseModel):
    streak_days: int
    total_points: int
    current_level: str
    next_level_points: int
    progress_pct: float
    badges: List[BadgeInfo]

