from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.modules.user_profile.router import get_current_user_id
from app.modules.nutrition.schemas import (
    BMICalculateResponse,
    MealLogCreateRequest,
    MealLogResponse,
    DailyNutritionSummaryResponse
)
from app.modules.nutrition.service import NutritionService

router = APIRouter(prefix="", tags=["Nutrition & Meal Planner"])

@router.get("/bmi/calculate", response_model=BMICalculateResponse)
def calculate_bmi(
    height_cm: float = Query(..., ge=40, le=250),
    weight_kg: float = Query(..., ge=20, le=300)
):
    return NutritionService.calculate_bmi(height_cm=height_cm, weight_kg=weight_kg)

@router.post("/meal-log", response_model=MealLogResponse)
def add_meal_log(
    req: MealLogCreateRequest,
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    log = NutritionService.create_meal_log(db, current_user_id, req)
    return MealLogResponse(
        id=log.id,
        item_name=log.item_name,
        meal_type=log.meal_type,
        calorie=log.calorie,
        protein_g=log.protein_g,
        carb_g=log.carb_g,
        fat_g=log.fat_g,
        sugar_g=log.sugar_g,
        water_ml=log.water_ml,
        logged_at=log.logged_at
    )

@router.get("/meal-log/today-summary", response_model=DailyNutritionSummaryResponse)
def get_today_summary(
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    return NutritionService.get_today_summary(db, current_user_id)
