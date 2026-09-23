from datetime import datetime, date
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.models import MealLog, NutritionProfile, NutritionTarget
from app.modules.nutrition.schemas import (
    BMICalculateResponse,
    MealLogCreateRequest,
    MealLogResponse,
    DailyNutritionSummaryResponse
)

class NutritionService:
    @staticmethod
    def calculate_bmi(height_cm: float, weight_kg: float) -> BMICalculateResponse:
        height_m = height_cm / 100.0
        bmi = round(weight_kg / (height_m * height_m), 1)

        # Standar Kemenkes RI / WHO Asia-Pasifik:
        # < 18.5: Berat Badan Kurang
        # 18.5 - 22.9: Normal
        # 23.0 - 24.9: Kelebihan Berat Badan (Overweight)
        # >= 25.0: Obesitas
        if bmi < 18.5:
            cat = "Berat Badan Kurang"
            cat_id = "underweight"
            color = "dark-amethyst"
            rec = "Tingkatkan asupan kalori padat gizi dan konsumsi protein berkualitas untuk mencapai berat badan ideal."
            is_risk = True
        elif bmi <= 22.9:
            cat = "Normal (Ideal)"
            cat_id = "normal"
            color = "frozen-water"
            rec = "Pertahankan pola makan gizi seimbang dan aktivitas fisik teratur harian Anda."
            is_risk = False
        elif bmi <= 24.9:
            cat = "Kelebihan Berat Badan"
            cat_id = "overweight"
            color = "turquoise"
            rec = "Perhatikan porsi makan, batasi gula dan lemak jenuh, serta tingkatkan durasi aktivitas fisik."
            is_risk = False
        else:
            cat = "Obesitas"
            cat_id = "obese"
            color = "rich-cerulean"
            rec = "Disarankan untuk membatasi kalori berlebih dan berkonsultasi dengan Dokter Gizi untuk program penurunan berat badan aman."
            is_risk = True

        return BMICalculateResponse(
            bmi_score=bmi,
            category=cat,
            category_id=cat_id,
            color_token=color,
            recommendation=rec,
            is_risk=is_risk
        )

    @staticmethod
    def create_meal_log(db: Session, user_id: str, req: MealLogCreateRequest) -> MealLog:
        log = MealLog(
            user_id=user_id,
            item_name=req.item_name,
            meal_type=req.meal_type,
            calorie=req.calorie,
            protein_g=req.protein_g,
            carb_g=req.carb_g,
            fat_g=req.fat_g,
            sugar_g=req.sugar_g,
            water_ml=req.water_ml,
            logged_at=datetime.utcnow()
        )
        db.add(log)
        db.commit()
        db.refresh(log)
        return log

    @staticmethod
    def get_today_summary(db: Session, user_id: str) -> DailyNutritionSummaryResponse:
        today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
        
        # Get target from profile
        profile = db.query(NutritionProfile).filter(NutritionProfile.user_id == user_id).first()
        target = profile.nutrition_target if profile else None

        target_cal = target.calorie_target if target else 2000.0
        target_prot = target.protein_g if target else 75.0
        target_carb = target.carb_g if target else 250.0
        target_fat = target.fat_g if target else 55.0
        target_water = target.water_ml if target else 2000.0

        logs = (
            db.query(MealLog)
            .filter(MealLog.user_id == user_id, MealLog.logged_at >= today_start)
            .order_by(MealLog.logged_at.desc())
            .all()
        )

        curr_cal = sum(l.calorie for l in logs)
        curr_prot = sum(l.protein_g for l in logs)
        curr_carb = sum(l.carb_g for l in logs)
        curr_fat = sum(l.fat_g for l in logs)
        curr_water = sum(l.water_ml for l in logs)

        cal_pct = round((curr_cal / target_cal * 100) if target_cal > 0 else 0, 1)
        water_pct = round((curr_water / target_water * 100) if target_water > 0 else 0, 1)

        status = "on_track"
        if curr_water < (target_water * 0.4):
            status = "need_hydration"
        elif curr_cal < (target_cal * 0.3):
            status = "need_calories"
        elif curr_cal > (target_cal * 1.15):
            status = "exceeded"

        recent_logs = [
            MealLogResponse(
                id=l.id,
                item_name=l.item_name,
                meal_type=l.meal_type,
                calorie=l.calorie,
                protein_g=l.protein_g,
                carb_g=l.carb_g,
                fat_g=l.fat_g,
                sugar_g=l.sugar_g,
                water_ml=l.water_ml,
                logged_at=l.logged_at
            )
            for l in logs
        ]

        return DailyNutritionSummaryResponse(
            target_calorie=target_cal,
            current_calorie=round(curr_cal, 1),
            calorie_percentage=cal_pct,
            target_protein_g=target_prot,
            current_protein_g=round(curr_prot, 1),
            target_carb_g=target_carb,
            current_carb_g=round(curr_carb, 1),
            target_fat_g=target_fat,
            current_fat_g=round(curr_fat, 1),
            target_water_ml=target_water,
            current_water_ml=round(curr_water, 1),
            water_percentage=water_pct,
            status=status,
            recent_logs=recent_logs
        )
