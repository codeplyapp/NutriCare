from typing import List
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.modules.user_profile.router import get_current_user_id
from app.modules.consultation.schemas import (
    DoctorResponse,
    ConsultationBookRequest,
    ConsultationResponse
)
from app.modules.consultation.service import ConsultationService

router = APIRouter(prefix="", tags=["Dokter Gizi Online"])

@router.get("/doctors", response_model=List[DoctorResponse])
def get_doctors(db: Session = Depends(get_db)):
    doctors = ConsultationService.list_doctors(db)
    return [
        DoctorResponse(
            id=d.id,
            name=d.name,
            specialty=d.specialty,
            affiliation=d.affiliation,
            rating=d.rating,
            photo_url=d.photo_url,
            fee=d.fee,
            available_days=d.available_days,
            is_available=d.is_available
        )
        for d in doctors
    ]

@router.post("/consultations/book", response_model=ConsultationResponse)
def book_consultation(
    req: ConsultationBookRequest,
    request: Request,
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    ip = request.client.host if request.client else "127.0.0.1"
    c = ConsultationService.book_consultation(db, current_user_id, req, ip_address=ip)
    return ConsultationResponse(
        id=c.id,
        user_id=c.user_id,
        doctor_id=c.doctor_id,
        doctor_name=c.doctor.name if c.doctor else "Dokter Gizi",
        doctor_specialty=c.doctor.specialty if c.doctor else "Spesialis Gizi Klinis",
        scheduled_at=c.scheduled_at,
        status=c.status,
        consultation_type=c.consultation_type,
        call_token=c.call_token,
        notes=c.notes,
        created_at=c.created_at
    )

@router.get("/consultations/{id}", response_model=ConsultationResponse)
def get_consultation_detail(
    id: str,
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    c = ConsultationService.get_consultation(db, id, current_user_id)
    return ConsultationResponse(
        id=c.id,
        user_id=c.user_id,
        doctor_id=c.doctor_id,
        doctor_name=c.doctor.name if c.doctor else "Dokter Gizi",
        doctor_specialty=c.doctor.specialty if c.doctor else "Spesialis Gizi Klinis",
        scheduled_at=c.scheduled_at,
        status=c.status,
        consultation_type=c.consultation_type,
        call_token=c.call_token,
        notes=c.notes,
        created_at=c.created_at
    )

@router.get("/consultations", response_model=List[ConsultationResponse])
def get_user_consultations(
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    consultations = ConsultationService.list_user_consultations(db, current_user_id)
    return [
        ConsultationResponse(
            id=c.id,
            user_id=c.user_id,
            doctor_id=c.doctor_id,
            doctor_name=c.doctor.name if c.doctor else "Dokter Gizi",
            doctor_specialty=c.doctor.specialty if c.doctor else "Spesialis Gizi Klinis",
            scheduled_at=c.scheduled_at,
            status=c.status,
            consultation_type=c.consultation_type,
            call_token=c.call_token,
            notes=c.notes,
            created_at=c.created_at
        )
        for c in consultations
    ]
