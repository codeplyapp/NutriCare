import uuid
from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.models import Doctor, Consultation
from app.core.audit import log_pdp_access
from app.modules.consultation.schemas import ConsultationBookRequest, ConsultationResponse

class ConsultationService:
    @staticmethod
    def list_doctors(db: Session):
        return db.query(Doctor).filter(Doctor.is_available == True).all()

    @staticmethod
    def book_consultation(db: Session, user_id: str, req: ConsultationBookRequest, ip_address: str = "127.0.0.1"):
        doctor = db.query(Doctor).filter(Doctor.id == req.doctor_id).first()
        if not doctor:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Dokter gizi tidak ditemukan"
            )

        # Generate mock token for video/voice call (Agora simulation)
        mock_token = f"agora_rtc_token_{uuid.uuid4().hex[:16]}"

        consultation = Consultation(
            user_id=user_id,
            doctor_id=req.doctor_id,
            scheduled_at=req.scheduled_at,
            status="confirmed",
            call_token=mock_token,
            consultation_type=req.consultation_type,
            notes=req.notes
        )
        db.add(consultation)
        db.commit()
        db.refresh(consultation)

        log_pdp_access(
            db,
            user_id,
            "BOOK_CONSULTATION",
            "consultations",
            ip_address,
            f"Booking jadwal dokter {doctor.name} pada {req.scheduled_at}"
        )

        return consultation

    @staticmethod
    def get_consultation(db: Session, consultation_id: str, user_id: str):
        consultation = db.query(Consultation).filter(
            Consultation.id == consultation_id,
            Consultation.user_id == user_id
        ).first()
        if not consultation:
            raise HTTPException(status_code=404, detail="Konsultasi tidak ditemukan")
        return consultation

    @staticmethod
    def list_user_consultations(db: Session, user_id: str):
        return db.query(Consultation).filter(Consultation.user_id == user_id).order_by(Consultation.scheduled_at.desc()).all()
