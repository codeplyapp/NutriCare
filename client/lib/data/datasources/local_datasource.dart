import 'package:shared_preferences/shared_preferences.dart';

class LocalDataSource {
  static const _keyToken = 'jwt_token';
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyHasProfile = 'has_nutrition_profile';

  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String userName,
    required bool hasProfile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    await prefs.setBool(_keyHasProfile, hasProfile);
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

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyHasProfile);
  }
}
