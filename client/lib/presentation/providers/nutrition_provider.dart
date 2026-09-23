import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';

class NutritionState {
  final DailySummaryEntity? summary;
  final BMICalculateEntity? bmiResult;
  final bool isLoading;
  final String? errorMessage;

  const NutritionState({
    this.summary,
    this.bmiResult,
    this.isLoading = false,
    this.errorMessage,
  });

  NutritionState copyWith({
    DailySummaryEntity? summary,
    BMICalculateEntity? bmiResult,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NutritionState(
      summary: summary ?? this.summary,
      bmiResult: bmiResult ?? this.bmiResult,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NutritionNotifier extends StateNotifier<NutritionState> {
  final Ref _ref;

  NutritionNotifier(this._ref) : super(const NutritionState()) {
    loadTodaySummary();
  }

  Future<void> loadTodaySummary() async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(repositoryProvider);
      final summary = await repo.getTodaySummary();
      state = state.copyWith(isLoading: false, summary: summary);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addMealLog({
    required String itemName,
    required String mealType,
    required double calorie,
    double proteinG = 0,
    double carbG = 0,
    double fatG = 0,
    double sugarG = 0,
    double waterMl = 0,
  }) async {
    try {
      final repo = _ref.read(repositoryProvider);
      await repo.addMealLog(
        itemName: itemName,
        mealType: mealType,
        calorie: calorie,
        proteinG: proteinG,
        carbG: carbG,
        fatG: fatG,
        sugarG: sugarG,
        waterMl: waterMl,
      );
      await loadTodaySummary();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> calculateBMI(double heightCm, double weightKg) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(repositoryProvider);
      final res = await repo.calculateBMI(heightCm, weightKg);
      state = state.copyWith(isLoading: false, bmiResult: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final nutritionProvider = StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  return NutritionNotifier(ref);
});
