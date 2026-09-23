import os
import re
import logging
from datetime import datetime
from typing import Optional, Tuple
from sqlalchemy.orm import Session
import google.generativeai as genai

from app.core.config import settings
from app.models.models import ChatMessage, NutritionProfile, User
from app.modules.ai_gateway.schemas import ChatMessageResponse

logger = logging.getLogger(__name__)

STANDARD_DISCLAIMER = "Informasi ini bersifat edukasi gizi dan bukan pengganti diagnosis medis langsung. Konsultasikan dengan Dokter Gizi profesional untuk penanganan klinis yang akurat."

# Serious health trigger keywords for Guardrail Escalation
RISK_KEYWORDS = [
    r"gula darah (>|di atas)?\s*3\d\d|4\d\d|5\d\d",
    r"ketoasidosis",
    r"nyeri dada",
    r"pingsan",
    r"muntah darah",
    r"anoreksia",
    r"bulimia",
    r"bengkak.*ginjal",
    r"tensinya 1[8-9]\d|2\d\d",
    r"sesak napas.*makan",
    r"alergi parah.*bengkak"
]

FAQ_RESPONSES = {
    "berapa kebutuhan air": "Kebutuhan air standar Anda dihitung sekitar 30-35 ml per kg berat badan. Untuk menjaga hidrasi optimal, konsumsilah air putih secara berkala sebelum merasa haus.",
    "makanan untuk menurunkan berat badan": "Fokuslah pada makanan kaya serat (sayuran hijau, buah-buahan segar), protein tanpa lemak (dada ayam, telur, tahu, tempe), dan karbohidrat kompleks (nasi merah, oatmeal) dengan defisit kalori terukur.",
    "cara hitung kalori": "Kebutuhan kalori harian dihitung menggunakan rumus Mifflin-St Jeor dengan mempertimbangkan berat badan, tinggi badan, usia, jenis kelamin, dan faktor aktivitas harian Anda."
}

class AIGatewayService:
    @staticmethod
    def _detect_health_risk(message: str) -> Tuple[bool, Optional[str]]:
        msg_lower = message.lower()
        for pattern in RISK_KEYWORDS:
            if re.search(pattern, msg_lower):
                return True, "Terdeteksi indikasi kondisi kesehatan yang memerlukan perhatian medis profesional."
        return False, None

    @staticmethod
    def _get_faq_match(message: str) -> Optional[str]:
        msg_lower = message.lower().strip()
        for key, ans in FAQ_RESPONSES.items():
            if key in msg_lower:
                return ans
        return None

    @staticmethod
    def generate_nutri_mate_reply(db: Session, user_id: str, user_message: str) -> ChatMessageResponse:
        # 1. Check risk guardrails
        is_risk, risk_reason = AIGatewayService._detect_health_risk(user_message)

        # 2. Retrieve user nutrition context
        user = db.query(User).filter(User.id == user_id).first()
        profile = db.query(NutritionProfile).filter(NutritionProfile.user_id == user_id).first()
        target = profile.nutrition_target if profile else None

        user_name = user.name if user else "Pengguna"
        user_context = (
            f"Data Pasien/Pengguna: Nama: {user_name}, "
            f"Umur: {profile.age if profile else '25'} tahun, "
            f"Gender: {profile.gender if profile else 'pria'}, "
            f"TB: {profile.height_cm if profile else '170'} cm, "
            f"BB: {profile.weight_kg if profile else '65'} kg, "
            f"Target Kalori: {target.calorie_target if target else '2000'} kcal/hari, "
            f"Target Air: {target.water_ml if target else '2000'} ml/hari, "
            f"Kondisi Khusus: {profile.special_condition if profile and profile.special_condition else 'Tidak ada'}."
        )

        # 3. Check FAQ cache
        faq_answer = AIGatewayService._get_faq_match(user_message)

        bot_reply_text = ""
        if faq_answer and not is_risk:
            bot_reply_text = faq_answer
        else:
            # 4. Attempt Gemini API Call if Key is present
            if settings.GEMINI_API_KEY and settings.GEMINI_API_KEY != "your_gemini_api_key_here":
                try:
                    genai.configure(api_key=settings.GEMINI_API_KEY)
                    model = genai.GenerativeModel("gemini-1.5-flash")
                    
                    system_prompt = (
                        "Anda adalah Nutri Mate, asisten kecerdasan buatan ahli gizi ramah dari NutriCare. "
                        "Tugas Anda adalah memberikan saran gizi seimbang, edukasi makanan, dan motivasi hidup sehat yang praktis dalam Bahasa Indonesia. "
                        "Gunakan konteks data profil pengguna berikut untuk membuat jawaban lebih personal:\n"
                        f"{user_context}\n\n"
                        "Aturan penting:\n"
                        "1. Jika pengguna bertanya tentang keluhan penyakit berat atau gejala darurat, jawab dengan empati dan sarankan konsultasi langsung dengan dokter gizi.\n"
                        "2. Buat penjelasan ringkas, terstruktur (bullet point jika perlu), dan mudah dimengerti."
                    )
                    
                    full_prompt = f"{system_prompt}\n\nPertanyaan Pengguna: {user_message}"
                    response = model.generate_content(full_prompt)
                    if response and response.text:
                        bot_reply_text = response.text.strip()
                except Exception as e:
                    logger.error(f"Gemini API Error: {e}")
                    bot_reply_text = ""

            # Fallback smart response if API key is not configured or fails
            if not bot_reply_text:
                if is_risk:
                    bot_reply_text = (
                        f"Halo {user_name}, terima kasih telah bercerita. Berdasarkan gejala/kondisi yang Anda sampaikan, "
                        "hal ini berpotensi memerlukan penanganan medis spesifik. Sangat disarankan untuk segera berkonsultasi "
                        "langsung dengan spesialis Nutri Doc di NutriCare agar mendapatkan evaluasi klinis dan rencana nutrisi yang aman."
                    )
                else:
                    bot_reply_text = (
                        f"Halo {user_name}! Berdasarkan profil gizi Anda (target energi harian sekitar "
                        f"{int(target.calorie_target) if target else 2000} kcal dan hidrasi {int(target.water_ml) if target else 2000} ml), "
                        f"untuk pertanyaan mengenai '{user_message}':\n\n"
                        "1. **Komposisi Makanan:** Pastikan piring makan Anda memenuhi pedoman Isi Piringku (50% sayur & buah, 25% karbohidrat kompleks, 25% lauk protein tinggi).\n"
                        "2. **Waktu Asupan:** Hindari melewatkan sarapan dan beri jeda 2-3 jam sebelum tidur malam.\n"
                        "3. **Pantau Progres:** Gunakan fitur Nutri Meal untuk mencatat makanan Anda hari ini agar target gizi tercapai optimal!"
                    )

        # 5. Save user message & bot message to database
        user_chat_record = ChatMessage(
            user_id=user_id,
            sender="user",
            message=user_message,
            is_escalated=False,
            sent_at=datetime.utcnow()
        )
        db.add(user_chat_record)

        bot_chat_record = ChatMessage(
            user_id=user_id,
            sender="nutri_mate",
            message=bot_reply_text,
            is_escalated=is_risk,
            sent_at=datetime.utcnow()
        )
        db.add(bot_chat_record)
        db.commit()
        db.refresh(bot_chat_record)

        return ChatMessageResponse(
            id=bot_chat_record.id,
            sender="nutri_mate",
            message=bot_reply_text,
            disclaimer=STANDARD_DISCLAIMER,
            should_escalate_to_doctor=is_risk,
            escalation_reason=risk_reason if is_risk else None,
            suggested_action_label="Konsultasi Nutri Doc" if is_risk else None,
            sent_at=bot_chat_record.sent_at
        )

    @staticmethod
    def get_history(db: Session, user_id: str):
        return (
            db.query(ChatMessage)
            .filter(ChatMessage.user_id == user_id)
            .order_by(ChatMessage.sent_at.asc())
            .all()
        )
