from fastapi import APIRouter, Depends, Request, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import oauth2_scheme, decode_access_token, create_access_token
from app.modules.user_profile.schemas import (
    UserRegisterRequest,
    UserLoginRequest,
    TokenResponse,
    ProfileCreateOrUpdateRequest,
    UserProfileResponse,
    NutritionTargetResponse
)
from app.modules.user_profile.service import UserProfileService
from app.models.models import NutritionProfile

router = APIRouter(prefix="", tags=["User & Profile"])

def get_current_user_id(token: str = Depends(oauth2_scheme)) -> str:
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token autentikasi tidak ditemukan"
        )
    user_id = decode_access_token(token)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token autentikasi tidak valid atau telah kedaluwarsa"
        )
    return user_id

@router.post("/auth/register", response_model=TokenResponse)
def register(req: UserRegisterRequest, request: Request, db: Session = Depends(get_db)):
    ip = request.client.host if request.client else "127.0.0.1"
    user = UserProfileService.register_user(db, req, ip_address=ip)
    access_token = create_access_token(subject=user.id)
    return TokenResponse(
        access_token=access_token,
        user_id=user.id,
        name=user.name,
        email=user.email,
        has_nutrition_profile=False
    )

@router.post("/auth/login", response_model=TokenResponse)
def login(req: UserLoginRequest, db: Session = Depends(get_db)):
    user = UserProfileService.authenticate_user(db, req)
    access_token = create_access_token(subject=user.id)
    has_profile = db.query(NutritionProfile).filter(NutritionProfile.user_id == user.id).first() is not None
    return TokenResponse(
        access_token=access_token,
        user_id=user.id,
        name=user.name,
        email=user.email,
        has_nutrition_profile=has_profile
    )

@router.post("/profile", response_model=UserProfileResponse)
def save_profile(
    req: ProfileCreateOrUpdateRequest,
    request: Request,
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    ip = request.client.host if request.client else "127.0.0.1"
    profile, target = UserProfileService.save_or_update_profile(db, current_user_id, req, ip_address=ip)
    user, _, _ = UserProfileService.get_user_profile(db, current_user_id, ip_address=ip)
    
    return UserProfileResponse(
        user_id=user.id,
        name=user.name,
        email=user.email,
        phone=user.phone,
        age=profile.age,
        gender=profile.gender,
        height_cm=profile.height_cm,
        weight_kg=profile.weight_kg,
        activity_level=profile.activity_level,
        special_condition=profile.special_condition,
        nutrition_target=NutritionTargetResponse(
            calorie_target=target.calorie_target,
            protein_g=target.protein_g,
            carb_g=target.carb_g,
            fat_g=target.fat_g,
            water_ml=target.water_ml
        ) if target else None,
        has_profile=True
    )

@router.get("/profile", response_model=UserProfileResponse)
def get_profile(
    request: Request,
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    ip = request.client.host if request.client else "127.0.0.1"
    user, profile, target = UserProfileService.get_user_profile(db, current_user_id, ip_address=ip)
    
    return UserProfileResponse(
        user_id=user.id,
        name=user.name,
        email=user.email,
        phone=user.phone,
        age=profile.age if profile else None,
        gender=profile.gender if profile else None,
        height_cm=profile.height_cm if profile else None,
        weight_kg=profile.weight_kg if profile else None,
        activity_level=profile.activity_level if profile else None,
        special_condition=profile.special_condition if profile else None,
        nutrition_target=NutritionTargetResponse(
            calorie_target=target.calorie_target,
            protein_g=target.protein_g,
            carb_g=target.carb_g,
            fat_g=target.fat_g,
            water_ml=target.water_ml
        ) if target else None,
        has_profile=profile is not None
    )

@router.get("/profile/nutrition-target", response_model=NutritionTargetResponse)
def get_nutrition_target(
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    profile = db.query(NutritionProfile).filter(NutritionProfile.user_id == current_user_id).first()
    if not profile or not profile.nutrition_target:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profil gizi belum diisi. Silakan lengkapi profil terlebih dahulu."
        )
    target = profile.nutrition_target
    return NutritionTargetResponse(
        calorie_target=target.calorie_target,
        protein_g=target.protein_g,
        carb_g=target.carb_g,
        fat_g=target.fat_g,
        water_ml=target.water_ml
    )
