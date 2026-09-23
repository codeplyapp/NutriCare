import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutricare/data/repositories/nutricare_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NutriCare Domain & Calculation Tests', () {
    final repo = NutriCareRepositoryImpl();

    test('BMI Calculation for Normal weight', () async {
      // 170cm, 65kg -> BMI = 65 / (1.7 * 1.7) = 22.5 (Normal)
      final res = await repo.calculateBMI(170, 65);
      expect(res.bmiScore, 22.5);
      expect(res.categoryId, 'normal');
      expect(res.isRisk, false);
    });

    test('BMI Calculation for Obese category', () async {
      // 165cm, 85kg -> BMI = 85 / (1.65 * 1.65) = 31.2 (Obese)
      final res = await repo.calculateBMI(165, 85);
      expect(res.bmiScore, 31.2);
      expect(res.categoryId, 'obese');
      expect(res.isRisk, true);
    });

    test('Mifflin-St Jeor Target Calculation', () async {
      final profile = await repo.saveProfile(
        age: 25,
        gender: 'pria',
        heightCm: 175,
        weightKg: 70,
        activityLevel: 'moderate',
      );

      expect(profile.target, isNotNull);
      expect(profile.target!.calorieTarget, greaterThan(2000));
      expect(profile.target!.waterMl, 70 * 35.0); // 2450 ml
    });
  });
}
