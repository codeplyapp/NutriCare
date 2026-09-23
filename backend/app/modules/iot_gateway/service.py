from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.models import DevicePairing, NutritionProfile, MealLog
from app.modules.iot_gateway.schemas import (
    DevicePairRequest,
    DeviceAckRequest,
    NutritionReminderEvaluationResponse
)
from app.modules.iot_gateway.adapter import get_device_adapter

class IoTGatewayService:
    @staticmethod
    def pair_device(db: Session, user_id: str, req: DevicePairRequest) -> DevicePairing:
        pairing = db.query(DevicePairing).filter(
            DevicePairing.user_id == user_id,
            DevicePairing.device_id == req.device_id
        ).first()

        if not pairing:
            pairing = DevicePairing(
                user_id=user_id,
                device_id=req.device_id,
                device_type=req.device_type,
                device_name=req.device_name,
                is_connected=True,
                battery_pct=90,
                last_sync_at=datetime.utcnow()
            )
            db.add(pairing)
        else:
            pairing.is_connected = True
            pairing.device_name = req.device_name
            pairing.device_type = req.device_type
            pairing.last_sync_at = datetime.utcnow()

        db.commit()
        db.refresh(pairing)
        return pairing

    @staticmethod
    def process_ack(db: Session, user_id: str, device_id: str, req: DeviceAckRequest):
        pairing = db.query(DevicePairing).filter(
            DevicePairing.device_id == device_id,
            DevicePairing.user_id == user_id
        ).first()

        if not pairing:
            raise HTTPException(status_code=404, detail="Perangkat belum dipasangkan")

        if req.battery_pct is not None:
            pairing.battery_pct = req.battery_pct
        pairing.last_sync_at = datetime.utcnow()
        pairing.is_connected = True
        db.commit()

        # Evaluasi apakah ada pending reminder
        reminder_eval = IoTGatewayService.evaluate_nutrition_gap(db, user_id, device_id)
        pending_msg = reminder_eval.reminder_message if reminder_eval.has_reminder else None

        return pairing, pending_msg

    @staticmethod
    def evaluate_nutrition_gap(db: Session, user_id: str, device_id: str) -> NutritionReminderEvaluationResponse:
        today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
        
        profile = db.query(NutritionProfile).filter(NutritionProfile.user_id == user_id).first()
        target = profile.nutrition_target if profile else None

        target_cal = target.calorie_target if target else 2000.0
        target_water = target.water_ml if target else 2000.0

        logs = db.query(MealLog).filter(
            MealLog.user_id == user_id,
            MealLog.logged_at >= today_start
        ).all()

        curr_cal = sum(l.calorie for l in logs)
        curr_water = sum(l.water_ml for l in logs)

        current_hour = datetime.utcnow().hour + 7  # WIB (UTC+7)
        current_hour = current_hour % 24

        has_reminder = False
        title = "NutriCare IoT"
        msg = "Pola gizi hari ini berjalan baik."
        vibration = "gentle"

        # Evaluasi Gap Gizi Real-time (FR-4.4)
        if curr_water < (target_water * 0.5) and current_hour >= 13:
            has_reminder = True
            title = "Waktunya Hidrasi 💧"
            msg = "Minum yuk! Asupan air kamu baru sebagian dari target harian."
            vibration = "pulse"
        elif curr_cal < (target_cal * 0.4) and current_hour >= 14:
            has_reminder = True
            title = "Waktunya Energi ⚡"
            msg = "Makan yang manis/padat gizi dulu yuk biar kerja makin lancar!"
            vibration = "gentle"
        elif curr_water < target_water and current_hour >= 19:
            has_reminder = True
            title = "Target Air Harian 💧"
            msg = f"Tinggal {int(target_water - curr_water)} ml lagi untuk penuhi hidrasi harianmu!"
            vibration = "gentle"

        return NutritionReminderEvaluationResponse(
            device_id=device_id,
            has_reminder=has_reminder,
            reminder_title=title,
            reminder_message=msg,
            vibration_pattern=vibration,
            evaluated_at=datetime.utcnow()
        )

    @staticmethod
    def get_paired_devices(db: Session, user_id: str):
        return db.query(DevicePairing).filter(DevicePairing.user_id == user_id).all()
