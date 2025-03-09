import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management
  static Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  static String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  static Future<void> setRefreshToken(String token) async {
    await _prefs.setString(_refreshTokenKey, token);
  }

  static String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  // User Data Management
  static Future<void> setUser(User user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static User? getUser() {
    final userStr = _prefs.getString(_userKey);
    if (userStr != null) {
      var userData = jsonDecode(userStr) as Map<String, dynamic>;
      return User.fromJson(userData, role: userData['role']);
    }
    return null;
  }

  // Clear All Data
  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Clear Auth Data
  static Future<void> clearAuthData() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userKey);
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return getToken() != null;
  }
}
