import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lưu cài đặt nhẹ: ngôn ngữ, giao diện sáng/tối (shared_preferences).
class PrefsStore {
  PrefsStore._(this._prefs);

  static const _kThemeMode = 'theme_mode';
  static const _kLanguage = 'language';

  final SharedPreferences _prefs;

  static Future<PrefsStore> create() async =>
      PrefsStore._(await SharedPreferences.getInstance());

  ThemeMode get themeMode {
    switch (_prefs.getString(_kThemeMode)) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark; // mặc định theo thiết kế: nền tối
    }
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_kThemeMode, mode.name);

  /// 'vi' hoặc 'en'.
  String get languageCode => _prefs.getString(_kLanguage) ?? 'vi';

  Future<void> setLanguageCode(String code) => _prefs.setString(_kLanguage, code);

  // Dùng cho cache dữ liệu (xem app_database.dart).
  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
  Future<void> remove(String key) => _prefs.remove(key);
}
