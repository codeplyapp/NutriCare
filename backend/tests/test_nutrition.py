import unittest
from app.modules.user_profile.service import calculate_mifflin_st_jeor
from app.modules.nutrition.service import NutritionService
from app.modules.ai_gateway.service import AIGatewayService
from app.modules.content.service import ContentService
from app.core.database import SessionLocal

class NutritionAndCurriculumTests(unittest.TestCase):
    def test_mifflin_st_jeor_male(self):
        res = calculate_mifflin_st_jeor(70, 175, 25, "pria", "moderate")
        self.assertGreater(res["calorie_target"], 2500)
        self.assertGreater(res["protein_g"], 0)
        self.assertGreater(res["carb_g"], 0)
        self.assertGreater(res["fat_g"], 0)
        self.assertEqual(res["water_ml"], 70 * 35.0)

    def test_bmi_calculation(self):
        res = NutritionService.calculate_bmi(170, 60)
        self.assertEqual(res.bmi_score, 20.8)
        self.assertEqual(res.category_id, "normal")
        self.assertFalse(res.is_risk)

        res_obese = NutritionService.calculate_bmi(170, 90)
        self.assertEqual(res_obese.bmi_score, 31.1)
        self.assertEqual(res_obese.category_id, "obese")
        self.assertTrue(res_obese.is_risk)

    def test_ai_guardrail_risk_detection(self):
        is_risk, reason = AIGatewayService._detect_health_risk("Dok, gula darah saya di atas 400 dan saya merasa pusing")
        self.assertTrue(is_risk)
        self.assertIsNotNone(reason)

        is_risk_normal, _ = AIGatewayService._detect_health_risk("Berapa porsi sayur yang baik untuk makan siang?")
        self.assertFalse(is_risk_normal)

    def test_curriculum_and_gamification(self):
        db = SessionLocal()
        try:
            modules = ContentService.list_modules(db, user_id="test-user")
            self.assertGreaterEqual(len(modules), 5)

            # Test progress
            prog = ContentService.get_user_progress(db, user_id="test-user")
            self.assertIsNotNone(prog.streak_days)
            self.assertIsNotNone(prog.badges)
            self.assertIsNotNone(prog.total_points)
        finally:
            db.close()

if __name__ == "__main__":
    unittest.main()

