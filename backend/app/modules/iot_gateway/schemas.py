from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class DevicePairRequest(BaseModel):
    device_id: str = Field(..., min_length=3)
    device_type: str = Field(default="smartwatch", description="apple_watch, wear_os, generic_ble")
    device_name: str = Field(default="NutriCare Watch")

class DevicePairResponse(BaseModel):
    id: str
    device_id: str
    device_type: str
    device_name: str
    is_connected: bool
    battery_pct: int
    last_sync_at: datetime
    message: str

class DeviceAckRequest(BaseModel):
    battery_pct: Optional[int] = Field(default=None, ge=0, le=100)
    heart_rate: Optional[int] = None
    step_count: Optional[int] = None

class DeviceAckResponse(BaseModel):
    device_id: str
    status: str
    pending_reminder: Optional[str] = None
    last_sync_at: datetime

class NutritionReminderEvaluationResponse(BaseModel):
    device_id: str
    has_reminder: bool
    reminder_title: str
    reminder_message: str
    vibration_pattern: str  # gentle, strong, pulse
    evaluated_at: datetime
