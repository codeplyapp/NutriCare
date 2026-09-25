import 'package:shared_preferences/shared_preferences.dart';

class LocalDataSource {
  static const _keyToken = 'jwt_token';
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyHasProfile = 'has_nutrition_profile';

  static const _keyEmailVerified = 'email_verified';
  static const _keyDraftName = 'draft_register_name';
  static const _keyDraftEmail = 'draft_register_email';
  static const _keyDraftTimestamp = 'draft_register_timestamp';
  static const _keyFailedAttempts = 'failed_login_attempts';
  static const _keyLockoutTimestamp = 'lockout_timestamp';

  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String userName,
    required bool hasProfile,
    bool isEmailVerified = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    await prefs.setBool(_keyHasProfile, hasProfile);
    await prefs.setBool(_keyEmailVerified, isEmailVerified);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  Future<bool> getHasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasProfile) ?? false;
  }

  Future<void> setHasProfile(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasProfile, value);
  }

  Future<bool> getIsEmailVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEmailVerified) ?? false;
  }

  Future<void> setIsEmailVerified(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEmailVerified, value);
  }

  // Draft Registration Cache (TTL 30 Menit)
  Future<void> saveRegisterDraft(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDraftName, name);
    await prefs.setString(_keyDraftEmail, email);
    await prefs.setInt(_keyDraftTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  Future<Map<String, String>?> getRegisterDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_keyDraftTimestamp);
    if (timestamp == null) return null;

    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
    if (age.inMinutes > 30) {
      await clearRegisterDraft();
      return null;
    }

    final name = prefs.getString(_keyDraftName);
    final email = prefs.getString(_keyDraftEmail);
    if (name == null && email == null) return null;

    return {
      'name': name ?? '',
      'email': email ?? '',
    };
  }

  Future<void> clearRegisterDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDraftName);
    await prefs.remove(_keyDraftEmail);
    await prefs.remove(_keyDraftTimestamp);
  }

  // Lockout Management
  Future<int> getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyFailedAttempts) ?? 0;
  }

  Future<void> setFailedAttempts(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFailedAttempts, count);
  }

  Future<int?> getLockoutTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLockoutTimestamp);
  }

  Future<void> setLockoutTimestamp(int? timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    if (timestamp == null) {
      await prefs.remove(_keyLockoutTimestamp);
    } else {
      await prefs.setInt(_keyLockoutTimestamp, timestamp);
    }
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyHasProfile);
    await prefs.remove(_keyEmailVerified);
  }
}
