import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefKeys {
  SharedPrefKeys._();
  
  static const String token = 'auth_token';
  static const String userId = 'user_id';
  static const String userPhone = 'user_phone';
  static const String userName = 'user_name';
}

class SharedPrefManager {
  final SharedPreferences _sharedPreferences;

  SharedPrefManager(this._sharedPreferences);

  // Setters
  Future<bool> setString(String key, String value) async {
    return await _sharedPreferences.setString(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _sharedPreferences.setBool(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    return await _sharedPreferences.setInt(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _sharedPreferences.setDouble(key, value);
  }

  // Getters
  String? getString(String key) {
    return _sharedPreferences.getString(key);
  }

  bool? getBool(String key) {
    return _sharedPreferences.getBool(key);
  }

  int? getInt(String key) {
    return _sharedPreferences.getInt(key);
  }

  double? getDouble(String key) {
    return _sharedPreferences.getDouble(key);
  }

  // Auth helper methods
  String? getAuthToken() {
    return getString(SharedPrefKeys.token);
  }

  Future<bool> setAuthToken(String token) async {
    return await setString(SharedPrefKeys.token, token);
  }

  Future<bool> saveUserData({
    required String token,
    required String userId,
    required String phone,
    required String name,
  }) async {
    final tSaved = await setString(SharedPrefKeys.token, token);
    final idSaved = await setString(SharedPrefKeys.userId, userId);
    final phoneSaved = await setString(SharedPrefKeys.userPhone, phone);
    final nameSaved = await setString(SharedPrefKeys.userName, name);
    return tSaved && idSaved && phoneSaved && nameSaved;
  }

  // Cleaners
  Future<bool> remove(String key) async {
    return await _sharedPreferences.remove(key);
  }

  Future<bool> clearAll() async {
    return await _sharedPreferences.clear();
  }
}
