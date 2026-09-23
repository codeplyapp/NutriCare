from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class DoctorResponse(BaseModel):
    id: str
    name: str
    specialty: str
    affiliation: str
    rating: float
    photo_url: Optional[str]
    fee: float
    available_days: str
    is_available: bool

class ConsultationBookRequest(BaseModel):
    doctor_id: str
    scheduled_at: datetime
    consultation_type: str = Field(default="chat", description="chat atau video_call")
    notes: Optional[str] = None

class ConsultationResponse(BaseModel):
    id: str
    user_id: str
    doctor_id: str
    doctor_name: str
    doctor_specialty: str
    scheduled_at: datetime
    status: str
    consultation_type: str
    call_token: Optional[str]
    notes: Optional[str]
    created_at: datetime
