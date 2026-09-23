import json
import uuid
from datetime import datetime, timedelta
from typing import Optional, List
from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.models import (
    Article, User, StudyModule, Flashcard, QuizQuestion,
    QuizAttempt, Certificate, UserProgress, saved_articles_table
)
from app.modules.content.schemas import (
    ArticleResponse, BookmarkToggleResponse, StudyModuleResponse,
    FlashcardResponse, QuizQuestionResponse, QuizSubmitResponse,
    CertificateResponse, UserProgressResponse, BadgeInfo
)

AVAILABLE_BADGES = [
    {
        "id": "pionir_gizi",
        "title": "Pionir Gizi",
        "description": "Mendaftar dan melengkapi profil gizi awal NutriCare",
        "icon_name": "eco"
    },
    {
        "id": "hidrasi_konsisten",
        "title": "Pejuang Hidrasi",
        "description": "Mencapai target asupan air harian secara konsisten",
        "icon_name": "water_drop"
    },
    {
        "id": "master_kuis",
        "title": "Pakar Kuis Gizi",
        "description": "Lulus kuis modul edukasi gizi dengan nilai sempurna (100)",
        "icon_name": "workspace_premium"
    },
    {
        "id": "sertifikasi_gizi",
        "title": "Gizi Seimbang Bersertifikat",
        "description": "Lulus Simulasi Ujian Akhir Kurikulum NutriCare standar Kemenkes RI",
        "icon_name": "verified"
    },
    {
        "id": "streak_7",
        "title": "Disiplin 7 Hari",
        "description": "Mempertahankan streak pencatatan nutrisi selama 7 hari berturut-turut",
        "icon_name": "local_fire_department"
    }
]

class ContentService:
    @staticmethod
    def list_articles(db: Session, user_id: Optional[str] = None, category: Optional[str] = None) -> List[ArticleResponse]:
        query = db.query(Article)
        if category and category.lower() != "semua":
            query = query.filter(Article.category.ilike(f"%{category}%"))
        articles = query.order_by(Article.created_at.desc()).all()

        saved_article_ids = set()
        if user_id:
            user = db.query(User).filter(User.id == user_id).first()
            if user:
                saved_article_ids = {a.id for a in user.saved_articles}

        return [
            ArticleResponse(
                id=a.id,
                title=a.title,
                category=a.category,
                summary=a.summary,
                content=a.content,
                content_url=a.content_url,
                image_url=a.image_url,
                read_time_minutes=a.read_time_minutes,
                is_bookmarked=a.id in saved_article_ids,
                created_at=a.created_at
            )
            for a in articles
        ]

    @staticmethod
    def get_article(db: Session, article_id: str, user_id: Optional[str] = None) -> ArticleResponse:
        a = db.query(Article).filter(Article.id == article_id).first()
        if not a:
            raise HTTPException(status_code=404, detail="Artikel tidak ditemukan")

        is_saved = False
        if user_id:
            user = db.query(User).filter(User.id == user_id).first()
            if user and a in user.saved_articles:
                is_saved = True

        return ArticleResponse(
            id=a.id,
            title=a.title,
            category=a.category,
            summary=a.summary,
            content=a.content,
            content_url=a.content_url,
            image_url=a.image_url,
            read_time_minutes=a.read_time_minutes,
            is_bookmarked=is_saved,
            created_at=a.created_at
        )

    @staticmethod
    def toggle_bookmark(db: Session, user_id: str, article_id: str) -> BookmarkToggleResponse:
        user = db.query(User).filter(User.id == user_id).first()
        article = db.query(Article).filter(Article.id == article_id).first()

        if not user or not article:
            raise HTTPException(status_code=404, detail="User atau artikel tidak ditemukan")

        if article in user.saved_articles:
            user.saved_articles.remove(article)
            db.commit()
            return BookmarkToggleResponse(
                article_id=article_id,
                is_bookmarked=False,
                message="Artikel dihapus dari simpanan"
            )
        else:
            user.saved_articles.append(article)
            db.commit()
            return BookmarkToggleResponse(
                article_id=article_id,
                is_bookmarked=True,
                message="Artikel berhasil disimpan ke bookmark"
            )

    # ----------------- KURIKULUM GIZI BERJENJANG -----------------

    @staticmethod
    def list_modules(db: Session, user_id: Optional[str] = None) -> List[StudyModuleResponse]:
        modules = db.query(StudyModule).order_by(StudyModule.level_order.asc()).all()

        user_attempts = {}
        if user_id:
            attempts = db.query(QuizAttempt).filter(
                QuizAttempt.user_id == user_id,
                QuizAttempt.is_exam == False
            ).all()
            for att in attempts:
                if att.module_id not in user_attempts or att.score > user_attempts[att.module_id]:
                    user_attempts[att.module_id] = att.score

        res = []
        for m in modules:
            best_sc = user_attempts.get(m.id)
            res.append(StudyModuleResponse(
                id=m.id,
                title=m.title,
                category=m.category,
                level_order=m.level_order,
                description=m.description,
                content=m.content,
                icon_name=m.icon_name or "menu_book",
                estimated_minutes=m.estimated_minutes or 10,
                is_completed=best_sc is not None and best_sc >= 70.0,
                best_score=best_sc,
                flashcards_count=len(m.flashcards),
                quiz_count=len(m.quiz_questions)
            ))
        return res

    @staticmethod
    def get_module(db: Session, module_id: str, user_id: Optional[str] = None) -> StudyModuleResponse:
        m = db.query(StudyModule).filter(StudyModule.id == module_id).first()
        if not m:
            raise HTTPException(status_code=404, detail="Modul kurikulum tidak ditemukan")

        best_sc = None
        if user_id:
            attempt = db.query(QuizAttempt).filter(
                QuizAttempt.user_id == user_id,
                QuizAttempt.module_id == module_id,
                QuizAttempt.is_exam == False
            ).order_by(QuizAttempt.score.desc()).first()
            if attempt:
                best_sc = attempt.score

        return StudyModuleResponse(
            id=m.id,
            title=m.title,
            category=m.category,
            level_order=m.level_order,
            description=m.description,
            content=m.content,
            icon_name=m.icon_name or "menu_book",
            estimated_minutes=m.estimated_minutes or 10,
            is_completed=best_sc is not None and best_sc >= 70.0,
            best_score=best_sc,
            flashcards_count=len(m.flashcards),
            quiz_count=len(m.quiz_questions)
        )

    @staticmethod
    def list_flashcards(db: Session, module_id: str) -> List[FlashcardResponse]:
        cards = db.query(Flashcard).filter(Flashcard.module_id == module_id).all()
        return [
            FlashcardResponse(
                id=c.id,
                module_id=c.module_id,
                term=c.term,
                definition=c.definition,
                practical_tip=c.practical_tip
            )
            for c in cards
        ]

    @staticmethod
    def get_quiz_questions(db: Session, module_id: str) -> List[QuizQuestionResponse]:
        questions = db.query(QuizQuestion).filter(
            QuizQuestion.module_id == module_id,
            QuizQuestion.is_exam == False
        ).all()
        return [
            QuizQuestionResponse(
                id=q.id,
                module_id=q.module_id,
                question=q.question,
                options=json.loads(q.options_json),
                correct_index=q.correct_index,
                explanation=q.explanation,
                is_case_study=q.is_case_study or False,
                is_exam=q.is_exam or False
            )
            for q in questions
        ]

    @staticmethod
    def submit_quiz(db: Session, user_id: str, module_id: str, answers: List[int]) -> QuizSubmitResponse:
        questions = db.query(QuizQuestion).filter(
            QuizQuestion.module_id == module_id,
            QuizQuestion.is_exam == False
        ).all()

        if not questions:
            raise HTTPException(status_code=400, detail="Tidak ada pertanyaan untuk modul ini")

        total = len(questions)
        correct_count = 0
        reviews = []

        for i, q in enumerate(questions):
            opts = json.loads(q.options_json)
            user_choice = answers[i] if i < len(answers) else -1
            is_correct = (user_choice == q.correct_index)
            if is_correct:
                correct_count += 1

            reviews.append({
                "question": q.question,
                "user_answer": opts[user_choice] if 0 <= user_choice < len(opts) else "Tidak dijawab",
                "correct_answer": opts[q.correct_index],
                "is_correct": is_correct,
                "explanation": q.explanation
            })

        score = (correct_count / total) * 100.0 if total > 0 else 0.0
        passed = score >= 70.0

        # Save Attempt
        attempt = QuizAttempt(
            user_id=user_id,
            module_id=module_id,
            score=score,
            total_questions=total,
            correct_answers=correct_count,
            passed=passed,
            is_exam=False
        )
        db.add(attempt)

        # Gamification: Update Progress & Points
        points_earned = int(score * 1.5) + (50 if passed else 10)
        new_badge = ContentService._award_progress_and_badge(db, user_id, points_earned, score)

        db.commit()

        return QuizSubmitResponse(
            module_id=module_id,
            score=score,
            total_questions=total,
            correct_answers=correct_count,
            passed=passed,
            points_earned=points_earned,
            streak_updated=True,
            new_badge=new_badge,
            explanation_review=reviews
        )

    # ----------------- SIMULASI UJIAN AKHIR & SERTIFIKAT -----------------

    @staticmethod
    def get_exam_questions(db: Session) -> List[QuizQuestionResponse]:
        questions = db.query(QuizQuestion).filter(QuizQuestion.is_exam == True).all()
        if not questions:
            # Fallback to general pool if no exam flag
            questions = db.query(QuizQuestion).limit(20).all()

        return [
            QuizQuestionResponse(
                id=q.id,
                module_id=q.module_id,
                question=q.question,
                options=json.loads(q.options_json),
                correct_index=q.correct_index,
                explanation=q.explanation,
                is_case_study=q.is_case_study or False,
                is_exam=True
            )
            for q in questions
        ]

    @staticmethod
    def submit_exam(db: Session, user_id: str, answers: List[int]) -> QuizSubmitResponse:
        questions = db.query(QuizQuestion).filter(QuizQuestion.is_exam == True).all()
        if not questions:
            questions = db.query(QuizQuestion).limit(20).all()

        total = len(questions)
        correct_count = 0
        reviews = []

        for i, q in enumerate(questions):
            opts = json.loads(q.options_json)
            user_choice = answers[i] if i < len(answers) else -1
            is_correct = (user_choice == q.correct_index)
            if is_correct:
                correct_count += 1

            reviews.append({
                "question": q.question,
                "user_answer": opts[user_choice] if 0 <= user_choice < len(opts) else "Tidak dijawab",
                "correct_answer": opts[q.correct_index],
                "is_correct": is_correct,
                "explanation": q.explanation
            })

        score = (correct_count / total) * 100.0 if total > 0 else 0.0
        passed = score >= 80.0  # Syarat kelulusan ujian akhir 80%

        attempt = QuizAttempt(
            user_id=user_id,
            module_id=None,
            score=score,
            total_questions=total,
            correct_answers=correct_count,
            passed=passed,
            is_exam=True
        )
        db.add(attempt)

        new_badge = None
        points_earned = int(score * 3.0)

        # Issue Certificate if passed
        user = db.query(User).filter(User.id == user_id).first()
        if passed and user:
            existing_cert = db.query(Certificate).filter(Certificate.user_id == user_id).first()
            if not existing_cert:
                cert_num = f"NC-GIZI-{datetime.utcnow().strftime('%Y%m%d')}-{uuid.uuid4().hex[:6].upper()}"
                cert = Certificate(
                    user_id=user_id,
                    certificate_number=cert_num,
                    title="Sertifikat Kompetensi Gizi Seimbang NutriCare",
                    recipient_name=user.name,
                    verification_code=f"VERIF-{uuid.uuid4().hex[:8].upper()}"
                )
                db.add(cert)
                new_badge = "sertifikasi_gizi"

        ContentService._award_progress_and_badge(db, user_id, points_earned, score, force_badge=new_badge)
        db.commit()

        return QuizSubmitResponse(
            module_id="final-exam",
            score=score,
            total_questions=total,
            correct_answers=correct_count,
            passed=passed,
            points_earned=points_earned,
            streak_updated=True,
            new_badge=new_badge or ("sertifikasi_gizi" if passed else None),
            explanation_review=reviews
        )

    @staticmethod
    def list_certificates(db: Session, user_id: str) -> List[CertificateResponse]:
        certs = db.query(Certificate).filter(Certificate.user_id == user_id).order_by(Certificate.issued_at.desc()).all()
        return [
            CertificateResponse(
                id=c.id,
                certificate_number=c.certificate_number,
                title=c.title,
                recipient_name=c.recipient_name,
                issued_at=c.issued_at,
                verification_code=c.verification_code
            )
            for c in certs
        ]

    # ----------------- GAMIFIKASI PRIVAT -----------------

    @staticmethod
    def get_user_progress(db: Session, user_id: str) -> UserProgressResponse:
        prog = db.query(UserProgress).filter(UserProgress.user_id == user_id).first()
        if not prog:
            prog = UserProgress(
                user_id=user_id,
                streak_days=1,
                total_points=150,
                current_level="Nutri Novice",
                unlocked_badges_json=json.dumps(["pionir_gizi"])
            )
            db.add(prog)
            db.commit()
            db.refresh(prog)

        unlocked_ids = set(json.loads(prog.unlocked_badges_json or "[]"))

        badge_list = []
        for b in AVAILABLE_BADGES:
            badge_list.append(BadgeInfo(
                id=b["id"],
                title=b["title"],
                description=b["description"],
                icon_name=b["icon_name"],
                is_unlocked=b["id"] in unlocked_ids,
                unlocked_at=prog.updated_at.strftime("%d %b %Y") if b["id"] in unlocked_ids else None
            ))

        next_points = 500 if prog.total_points < 500 else 1500 if prog.total_points < 1500 else 3000
        prev_threshold = 0 if prog.total_points < 500 else 500 if prog.total_points < 1500 else 1500
        pct = ((prog.total_points - prev_threshold) / (next_points - prev_threshold)) if next_points > prev_threshold else 1.0

        return UserProgressResponse(
            streak_days=prog.streak_days,
            total_points=prog.total_points,
            current_level=prog.current_level,
            next_level_points=next_points,
            progress_pct=min(max(pct, 0.0), 1.0),
            badges=badge_list
        )

    @staticmethod
    def _award_progress_and_badge(db: Session, user_id: str, points: int, score: float, force_badge: Optional[str] = None) -> Optional[str]:
        prog = db.query(UserProgress).filter(UserProgress.user_id == user_id).first()
        if not prog:
            prog = UserProgress(
                user_id=user_id,
                streak_days=1,
                total_points=150,
                current_level="Nutri Novice",
                unlocked_badges_json=json.dumps(["pionir_gizi"])
            )
            db.add(prog)

        # Update streak
        now = datetime.utcnow()
        if prog.last_activity_date:
            diff = (now.date() - prog.last_activity_date.date()).days
            if diff == 1:
                prog.streak_days += 1
            elif diff > 1:
                prog.streak_days = 1
        else:
            prog.streak_days = 1

        prog.last_activity_date = now
        prog.total_points += points

        # Update Level
        if prog.total_points >= 1500:
            prog.current_level = "Master Nutrisi"
        elif prog.total_points >= 500:
            prog.current_level = "Gizi Seimbang Pro"
        else:
            prog.current_level = "Nutri Novice"

        # Check Badges
        unlocked = set(json.loads(prog.unlocked_badges_json or "[]"))
        new_badge_awarded = None

        if score >= 100.0 and "master_kuis" not in unlocked:
            unlocked.add("master_kuis")
            new_badge_awarded = "master_kuis"

        if prog.streak_days >= 7 and "streak_7" not in unlocked:
            unlocked.add("streak_7")
            new_badge_awarded = "streak_7"

        if force_badge and force_badge not in unlocked:
            unlocked.add(force_badge)
            new_badge_awarded = force_badge

        prog.unlocked_badges_json = json.dumps(list(unlocked))
        return new_badge_awarded

