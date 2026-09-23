from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.modules.user_profile.router import get_current_user_id
from app.modules.iot_gateway.schemas import (
    DevicePairRequest,
    DevicePairResponse,
    DeviceAckRequest,
    DeviceAckResponse,
    NutritionReminderEvaluationResponse
)
from app.modules.iot_gateway.service import IoTGatewayService

router = APIRouter(prefix="", tags=["IoT Gateway (Smartwatch)"])

@router.post("/devices/pair", response_model=DevicePairResponse)
def pair_device(
    req: DevicePairRequest,
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    p = IoTGatewayService.pair_device(db, current_user_id, req)
    return DevicePairResponse(
        id=p.id,
        device_id=p.device_id,
        device_type=p.device_type,
        device_name=p.device_name,
        is_connected=p.is_connected,
        battery_pct=p.battery_pct,
        last_sync_at=p.last_sync_at,
        message="Perangkat IoT berhasil dipasangkan dengan NutriCare"
    )

@router.post("/devices/{device_id}/ack", response_model=DeviceAckResponse)
def device_ack(
    device_id: str,
    req: DeviceAckRequest,
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    p, pending = IoTGatewayService.process_ack(db, current_user_id, device_id, req)
    return DeviceAckResponse(
        device_id=p.device_id,
        status="ok",
        pending_reminder=pending,
        last_sync_at=p.last_sync_at
    )

@router.get("/devices/{device_id}/reminder-eval", response_model=NutritionReminderEvaluationResponse)
def evaluate_reminder(
    device_id: str,
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    return IoTGatewayService.evaluate_nutrition_gap(db, current_user_id, device_id)

@router.get("/devices", response_model=List[DevicePairResponse])
def get_user_devices(
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    devices = IoTGatewayService.get_paired_devices(db, current_user_id)
    return [
        DevicePairResponse(
            id=d.id,
            device_id=d.device_id,
            device_type=d.device_type,
            device_name=d.device_name,
            is_connected=d.is_connected,
            battery_pct=d.battery_pct,
            last_sync_at=d.last_sync_at,
            message="Terkoneksi"
        )
        for d in devices
    ]
