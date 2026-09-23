from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class UserRegisterRequest(BaseModel):
    name: str = Field(..., min_length=2)
    email: str = Field(..., min_length=3)
    password: str = Field(..., min_length=6)
    phone: Optional[str] = None
    pdp_consent_given: bool = Field(..., description="Persetujuan eksplisit pemrosesan data kesehatan (UU PDP No. 27/2022)")

class UserLoginRequest(BaseModel):
    email: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    name: str
    email: str
    has_nutrition_profile: bool

class ProfileCreateOrUpdateRequest(BaseModel):
    age: int = Field(..., ge=1, le=120)
    gender: str = Field(..., description="pria atau wanita")
    height_cm: float = Field(..., ge=40, le=250)
    weight_kg: float = Field(..., ge=20, le=300)
    activity_level: str = Field(..., description="sedentary, light, moderate, heavy")
    special_condition: Optional[str] = None

class NutritionTargetResponse(BaseModel):
    calorie_target: float
    protein_g: float
    carb_g: float
    fat_g: float
    water_ml: float

class UserProfileResponse(BaseModel):
    user_id: str
    name: str
    email: str
    phone: Optional[str]
    age: Optional[int] = None
    gender: Optional[str] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    activity_level: Optional[str] = None
    special_condition: Optional[str] = None
    nutrition_target: Optional[NutritionTargetResponse] = None
    has_profile: bool
