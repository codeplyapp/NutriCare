import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/data/repositories/nutricare_repository_impl.dart';
import 'package:nutricare/domain/entities/entities.dart';

class GamificationState {
  final bool isLoading;
  final UserProgressEntity? progress;
  final String? newlyUnlockedBadge;
  final String? errorMessage;

  const GamificationState({
    this.isLoading = false,
    this.progress,
    this.newlyUnlockedBadge,
    this.errorMessage,
  });

  GamificationState copyWith({
    bool? isLoading,
    UserProgressEntity? progress,
    String? newlyUnlockedBadge,
    String? errorMessage,
  }) {
    return GamificationState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      newlyUnlockedBadge: newlyUnlockedBadge ?? this.newlyUnlockedBadge,
      errorMessage: errorMessage,
    );
  }
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  final NutriCareRepositoryImpl _repo;

  GamificationNotifier(this._repo) : super(const GamificationState()) {
    loadProgress();
  }

  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final prog = await _repo.getUserProgress();
      state = state.copyWith(progress: prog, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearNewBadge() {
    state = state.copyWith(newlyUnlockedBadge: null);
  }
}

final gamificationProvider = StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  final repo = NutriCareRepositoryImpl();
  return GamificationNotifier(repo);
});
