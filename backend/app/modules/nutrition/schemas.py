from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class BMICalculateRequest(BaseModel):
    height_cm: float = Field(..., ge=40, le=250)
    weight_kg: float = Field(..., ge=20, le=300)

class BMICalculateResponse(BaseModel):
    bmi_score: float
    category: str  # Kurang, Normal, Lebih, Obesitas
    category_id: str  # underweight, normal, overweight, obese
    color_token: str
    recommendation: str
    is_risk: bool

class MealLogCreateRequest(BaseModel):
    item_name: str = Field(..., min_length=1)
    meal_type: str = Field(default="snack", description="sarapan, makan_siang, makan_malam, snack, minuman")
    calorie: float = Field(..., ge=0)
    protein_g: float = Field(default=0.0, ge=0)
    carb_g: float = Field(default=0.0, ge=0)
    fat_g: float = Field(default=0.0, ge=0)
    sugar_g: float = Field(default=0.0, ge=0)
    water_ml: float = Field(default=0.0, ge=0)

class MealLogResponse(BaseModel):
    id: str
    item_name: str
    meal_type: str
    calorie: float
    protein_g: float
    carb_g: float
    fat_g: float
    sugar_g: float
    water_ml: float
    logged_at: datetime

class DailyNutritionSummaryResponse(BaseModel):
    target_calorie: float
    current_calorie: float
    calorie_percentage: float

    target_protein_g: float
    current_protein_g: float

    target_carb_g: float
    current_carb_g: float

    target_fat_g: float
    current_fat_g: float

    target_water_ml: float
    current_water_ml: float
    water_percentage: float

    status: str  # on_track, need_hydration, need_calories, exceeded
    recent_logs: List[MealLogResponse]
