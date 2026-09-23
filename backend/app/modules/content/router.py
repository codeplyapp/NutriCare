from typing import List, Optional
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import oauth2_scheme, decode_access_token
from app.modules.content.schemas import (
    ArticleResponse, BookmarkToggleResponse, StudyModuleResponse,
    FlashcardResponse, QuizQuestionResponse, QuizSubmitRequest,
    QuizSubmitResponse, CertificateResponse, UserProgressResponse
)
from app.modules.content.service import ContentService

router = APIRouter(prefix="/education", tags=["Health Education & Curriculum"])

def get_optional_user_id(token: Optional[str] = Depends(oauth2_scheme)) -> Optional[str]:
    if not token:
        return None
    return decode_access_token(token)

def get_required_user_id(token: Optional[str] = Depends(oauth2_scheme)) -> str:
    if not token:
        raise HTTPException(status_code=401, detail="Autentikasi diperlukan")
    uid = decode_access_token(token)
    if not uid:
        raise HTTPException(status_code=401, detail="Token tidak valid atau kedaluwarsa")
    return uid

# ----------------- ARTIKEL EDUKASI STATIS (MVP) -----------------

@router.get("/articles", response_model=List[ArticleResponse])
def get_articles(
    category: Optional[str] = Query(None),
    user_id: Optional[str] = Depends(get_optional_user_id),
    db: Session = Depends(get_db)
):
    return ContentService.list_articles(db, user_id=user_id, category=category)

@router.get("/articles/{id}", response_model=ArticleResponse)
def get_article_detail(
    id: str,
    user_id: Optional[str] = Depends(get_optional_user_id),
    db: Session = Depends(get_db)
):
    return ContentService.get_article(db, id, user_id=user_id)

@router.post("/articles/{id}/bookmark", response_model=BookmarkToggleResponse)
def toggle_bookmark(
    id: str,
    user_id: str = Depends(get_required_user_id),
    db: Session = Depends(get_db)
):
    return ContentService.toggle_bookmark(db, user_id, id)

# ----------------- KURIKULUM GIZI BERJENJANG (FASE 2 - ADAPTASI SIGAP) -----------------

@router.get("/curriculum/modules", response_model=List[StudyModuleResponse])
def get_curriculum_modules(
    user_id: Optional[str] = Depends(get_optional_user_id),
    db: Session = Depends(get_db)
):
    return ContentService.list_modules(db, user_id=user_id)

@router.get("/curriculum/modules/{id}", response_model=StudyModuleResponse)
def get_curriculum_module_detail(
    id: str,
    user_id: Optional[str] = Depends(get_optional_user_id),
    db: Session = Depends(get_db)
):
    return ContentService.get_module(db, id, user_id=user_id)

@router.get("/curriculum/modules/{id}/flashcards", response_model=List[FlashcardResponse])
def get_module_flashcards(
    id: str,
    db: Session = Depends(get_db)
):
    return ContentService.list_flashcards(db, id)

@router.get("/curriculum/modules/{id}/quiz", response_model=List[QuizQuestionResponse])
def get_module_quiz(
    id: str,
    db: Session = Depends(get_db)
):
    return ContentService.get_quiz_questions(db, id)

@router.post("/curriculum/modules/{id}/quiz/submit", response_model=QuizSubmitResponse)
def submit_module_quiz(
    id: str,
    payload: QuizSubmitRequest,
    user_id: str = Depends(get_required_user_id),
    db: Session = Depends(get_db)
):
    return ContentService.submit_quiz(db, user_id, id, payload.answers)

@router.get("/curriculum/exam", response_model=List[QuizQuestionResponse])
def get_final_exam(
    db: Session = Depends(get_db)
):
    return ContentService.get_exam_questions(db)

@router.post("/curriculum/exam/submit", response_model=QuizSubmitResponse)
def submit_final_exam(
    payload: QuizSubmitRequest,
    user_id: str = Depends(get_required_user_id),
    db: Session = Depends(get_db)
):
    return ContentService.submit_exam(db, user_id, payload.answers)

@router.get("/curriculum/certificates", response_model=List[CertificateResponse])
def get_user_certificates(
    user_id: str = Depends(get_required_user_id),
    db: Session = Depends(get_db)
):
    return ContentService.list_certificates(db, user_id)

@router.get("/progress", response_model=UserProgressResponse)
def get_gamification_progress(
    user_id: str = Depends(get_required_user_id),
    db: Session = Depends(get_db)
):
    return ContentService.get_user_progress(db, user_id)

