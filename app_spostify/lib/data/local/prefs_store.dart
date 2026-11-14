import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsStore {
  PrefsStore._(this._prefs);

  static const _kThemeMode = 'theme_mode';
  static const _kLanguage = 'language';
  static const _kOnboardingSeen = 'onboarding_seen';

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
        return ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_kThemeMode, mode.name);

  String get languageCode => _prefs.getString(_kLanguage) ?? 'vi';

  Future<void> setLanguageCode(String code) => _prefs.setString(_kLanguage, code);

  bool get hasSeenOnboarding => _prefs.getBool(_kOnboardingSeen) ?? false;

  Future<void> setOnboardingSeen([bool seen = true]) =>
      _prefs.setBool(_kOnboardingSeen, seen);
}
