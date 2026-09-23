from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.models import User, NutritionProfile, NutritionTarget
from app.core.security import get_password_hash, verify_password, create_access_token
from app.core.audit import log_pdp_access
from app.modules.user_profile.schemas import UserRegisterRequest, UserLoginRequest, ProfileCreateOrUpdateRequest

def calculate_mifflin_st_jeor(weight_kg: float, height_cm: float, age: int, gender: str, activity_level: str):
    """
    Kalkulasi Mifflin-St Jeor:
    Pria: BMR = (10 * W) + (6.25 * H) - (5 * A) + 5
    Wanita: BMR = (10 * W) + (6.25 * H) - (5 * A) - 161
    """
    g = gender.strip().lower()
    if g == "pria" or g == "male" or g == "l":
        bmr = (10 * weight_kg) + (6.25 * height_cm) - (5 * age) + 5
    else:
        bmr = (10 * weight_kg) + (6.25 * height_cm) - (5 * age) - 161

    # Activity multiplier
    act = activity_level.strip().lower()
    multipliers = {
        "sedentary": 1.2,       # Sedikit / tidak olahraga
        "light": 1.375,         # Olahraga ringan 1-3 hari/minggu
        "moderate": 1.55,       # Olahraga sedang 3-5 hari/minggu
        "heavy": 1.725,         # Olahraga berat 6-7 hari/minggu
        "very_heavy": 1.9
    }
    multiplier = multipliers.get(act, 1.2)
    tdee = round(bmr * multiplier, 1)

    # Standar Makronutrien Gizi Seimbang:
    # Karbohidrat: 55% total kalori (1g karbo = 4 kcal)
    # Protein: 20% total kalori (1g protein = 4 kcal)
    # Lemak: 25% total kalori (1g lemak = 9 kcal)
    # Air: 35 ml per kg berat badan
    carb_g = round((tdee * 0.55) / 4, 1)
    protein_g = round((tdee * 0.20) / 4, 1)
    fat_g = round((tdee * 0.25) / 9, 1)
    water_ml = round(weight_kg * 35.0, 0)

    return {
        "calorie_target": tdee,
        "protein_g": protein_g,
        "carb_g": carb_g,
        "fat_g": fat_g,
        "water_ml": water_ml
    }

class UserProfileService:
    @staticmethod
    def register_user(db: Session, req: UserRegisterRequest, ip_address: str = "127.0.0.1"):
        if not req.pdp_consent_given:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Persetujuan pemrosesan data pribadi (UU PDP) wajib disetujui."
            )

        existing = db.query(User).filter(User.email == req.email).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email sudah terdaftar."
            )

        user = User(
            name=req.name,
            email=req.email,
            phone=req.phone,
            hashed_password=get_password_hash(req.password),
            pdp_consent_given=req.pdp_consent_given
        )
        db.add(user)
        db.commit()
        db.refresh(user)

        log_pdp_access(db, user.id, "REGISTER_USER", "users", ip_address, "Registrasi akun dengan persetujuan UU PDP")
        return user

    @staticmethod
    def authenticate_user(db: Session, req: UserLoginRequest):
        user = db.query(User).filter(User.email == req.email).first()
        if not user or not verify_password(req.password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email atau password salah."
            )
        return user

    @staticmethod
    def save_or_update_profile(db: Session, user_id: str, req: ProfileCreateOrUpdateRequest, ip_address: str = "127.0.0.1"):
        profile = db.query(NutritionProfile).filter(NutritionProfile.user_id == user_id).first()
        if not profile:
            profile = NutritionProfile(
                user_id=user_id,
                age=req.age,
                gender=req.gender,
                height_cm=req.height_cm,
                weight_kg=req.weight_kg,
                activity_level=req.activity_level,
                special_condition=req.special_condition
            )
            db.add(profile)
            db.flush()
        else:
            profile.age = req.age
            profile.gender = req.gender
            profile.height_cm = req.height_cm
            profile.weight_kg = req.weight_kg
            profile.activity_level = req.activity_level
            profile.special_condition = req.special_condition

        # Hitung ulang target gizi otomatis (FR-1.2 & FR-1.3)
        calc = calculate_mifflin_st_jeor(
            req.weight_kg,
            req.height_cm,
            req.age,
            req.gender,
            req.activity_level
        )

        target = db.query(NutritionTarget).filter(NutritionTarget.profile_id == profile.id).first()
        if not target:
            target = NutritionTarget(
                profile_id=profile.id,
                calorie_target=calc["calorie_target"],
                protein_g=calc["protein_g"],
                carb_g=calc["carb_g"],
                fat_g=calc["fat_g"],
                water_ml=calc["water_ml"]
            )
            db.add(target)
        else:
            target.calorie_target = calc["calorie_target"]
            target.protein_g = calc["protein_g"]
            target.carb_g = calc["carb_g"]
            target.fat_g = calc["fat_g"]
            target.water_ml = calc["water_ml"]

        db.commit()
        db.refresh(profile)
        db.refresh(target)

        log_pdp_access(db, user_id, "SAVE_NUTRITION_PROFILE", "nutrition_profiles", ip_address, f"Target kalori baru: {calc['calorie_target']} kcal")
        return profile, target

    @staticmethod
    def get_user_profile(db: Session, user_id: str, ip_address: str = "127.0.0.1"):
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")

        profile = db.query(NutritionProfile).filter(NutritionProfile.user_id == user_id).first()
        target = None
        if profile:
            target = db.query(NutritionTarget).filter(NutritionTarget.profile_id == profile.id).first()

        log_pdp_access(db, user_id, "READ_PROFILE", "nutrition_profiles", ip_address, "Membaca data profil & gizi")
        return user, profile, target
