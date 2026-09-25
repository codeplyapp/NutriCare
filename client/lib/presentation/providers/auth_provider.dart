import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/data/datasources/local_datasource.dart';
import 'package:nutricare/data/repositories/nutricare_repository_impl.dart';
import 'package:nutricare/domain/entities/entities.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isEmailVerified;
  final bool hasProfile;
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;
  final int failedAttempts;
  final DateTime? lockoutUntil;

  const AuthState({
    this.isAuthenticated = false,
    this.isEmailVerified = true,
    this.hasProfile = false,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.failedAttempts = 0,
    this.lockoutUntil,
  });

  bool get isLockedOut {
    if (lockoutUntil == null) return false;
    return DateTime.now().isBefore(lockoutUntil!);
  }

  int get remainingLockoutSeconds {
    if (lockoutUntil == null) return 0;
    final diff = lockoutUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isEmailVerified,
    bool? hasProfile,
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    int? failedAttempts,
    DateTime? lockoutUntil,
    bool clearLockout = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      hasProfile: hasProfile ?? this.hasProfile,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutUntil: clearLockout ? null : (lockoutUntil ?? this.lockoutUntil),
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
    final isEmailVerified = await _localDataSource.getIsEmailVerified();
    final failedAttempts = await _localDataSource.getFailedAttempts();
    final lockoutMillis = await _localDataSource.getLockoutTimestamp();

    DateTime? lockoutUntil;
    if (lockoutMillis != null) {
      final lockDate = DateTime.fromMillisecondsSinceEpoch(lockoutMillis);
      if (DateTime.now().isBefore(lockDate)) {
        lockoutUntil = lockDate;
      } else {
        await _localDataSource.setLockoutTimestamp(null);
        await _localDataSource.setFailedAttempts(0);
      }
    }

    if (token != null && userId != null) {
      state = state.copyWith(
        isAuthenticated: true,
        isEmailVerified: isEmailVerified,
        hasProfile: hasProfile,
        failedAttempts: failedAttempts,
        lockoutUntil: lockoutUntil,
        user: UserEntity(
          id: userId,
          name: userName ?? 'Pengguna',
          email: '',
          hasProfile: hasProfile,
        ),
      );
    } else {
      state = state.copyWith(
        failedAttempts: failedAttempts,
        lockoutUntil: lockoutUntil,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    // Check brute force lockout
    if (state.isLockedOut) {
      state = state.copyWith(
        errorMessage: 'Akun sedang dikunci sementara karena terlalu banyak percobaan gagal. Silakan tunggu.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.login(email, password);

      // Reset lockout counter on success
      await _localDataSource.setFailedAttempts(0);
      await _localDataSource.setLockoutTimestamp(null);
      await _localDataSource.setIsEmailVerified(true);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isEmailVerified: true,
        hasProfile: user.hasProfile,
        user: user,
        failedAttempts: 0,
        clearLockout: true,
      );
      return true;
    } catch (e) {
      final newAttempts = state.failedAttempts + 1;
      await _localDataSource.setFailedAttempts(newAttempts);

      DateTime? newLockout;
      String errMsg = e.toString().replaceFirst('Exception: ', '');

      if (newAttempts >= 5) {
        newLockout = DateTime.now().add(const Duration(minutes: 5));
        await _localDataSource.setLockoutTimestamp(newLockout.millisecondsSinceEpoch);
        errMsg = 'Terlalu banyak percobaan gagal (5x). Akun dikunci sementara selama 5 menit demi keamanan.';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errMsg,
        failedAttempts: newAttempts,
        lockoutUntil: newLockout,
      );
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

      // Clean draft after successful registration
      await _localDataSource.clearRegisterDraft();
      await _localDataSource.setIsEmailVerified(false);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isEmailVerified: false,
        hasProfile: false,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulasi Google OAuth Login (terverifikasi otomatis)
      final dummyGoogleUser = UserEntity(
        id: 'google-user-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Pengguna Google NutriCare',
        email: 'user@google.com',
        hasProfile: false,
      );

      await _localDataSource.saveAuthData(
        token: 'mock-google-jwt-token',
        userId: dummyGoogleUser.id,
        userName: dummyGoogleUser.name,
        hasProfile: false,
        isEmailVerified: true,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isEmailVerified: true,
        hasProfile: false,
        user: dummyGoogleUser,
        failedAttempts: 0,
        clearLockout: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menghubungkan dengan Google: $e',
      );
      return false;
    }
  }

  Future<bool> sendVerificationEmail(String email) async {
    try {
      // Simulate/Trigger sending verification email
      await Future.delayed(const Duration(milliseconds: 600));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkEmailVerification(String email) async {
    try {
      // Simulate verification polling check
      await Future.delayed(const Duration(milliseconds: 500));
      // Mark verified
      await _localDataSource.setIsEmailVerified(true);
      state = state.copyWith(isEmailVerified: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Draft Cache Management
  Future<void> saveRegisterDraft(String name, String email) async {
    await _localDataSource.saveRegisterDraft(name, email);
  }

  Future<Map<String, String>?> getRegisterDraft() async {
    return _localDataSource.getRegisterDraft();
  }

  Future<void> clearRegisterDraft() async {
    await _localDataSource.clearRegisterDraft();
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
      await _localDataSource.setHasProfile(true);
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
