import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/data/datasources/local_datasource.dart';
import 'package:nutricare/data/repositories/nutricare_repository_impl.dart';
import 'package:nutricare/domain/entities/entities.dart';

class AuthState {
  final bool isAuthenticated;
  final bool hasProfile;
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.hasProfile = false,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? hasProfile,
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasProfile: hasProfile ?? this.hasProfile,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final NutriCareRepositoryImpl _repository;
  final LocalDataSource _localDataSource;

  AuthNotifier(this._repository, this._localDataSource) : super(const AuthState()) {
    checkInitialAuth();
  }

  Future<void> checkInitialAuth() async {
    final token = await _localDataSource.getToken();
    final userId = await _localDataSource.getUserId();
    final userName = await _localDataSource.getUserName();
    final hasProfile = await _localDataSource.getHasProfile();

    if (token != null && userId != null) {
      state = state.copyWith(
        isAuthenticated: true,
        hasProfile: hasProfile,
        user: UserEntity(
          id: userId,
          name: userName ?? 'Pengguna',
          email: '',
          hasProfile: hasProfile,
        ),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        hasProfile: user.hasProfile,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required bool consent,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.register(name, email, password, phone, consent);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        hasProfile: false,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> saveNutritionProfile({
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    String? specialCondition,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.saveProfile(
        age: age,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
        activityLevel: activityLevel,
        specialCondition: specialCondition,
      );
      state = state.copyWith(isLoading: false, hasProfile: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _localDataSource.clearAuth();
    state = const AuthState();
  }
}

final repositoryProvider = Provider<NutriCareRepositoryImpl>((ref) {
  return NutriCareRepositoryImpl();
});

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(repositoryProvider);
  final local = ref.watch(localDataSourceProvider);
  return AuthNotifier(repo, local);
});
