import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n/en.dart';
import '../core/l10n/vi.dart';
import '../data/local/prefs_store.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({PrefsStore? store})
      : _store = store,
        _themeMode = store?.themeMode ?? ThemeMode.dark,
        _languageCode = store?.languageCode ?? 'vi',
        _hasSeenOnboarding = store?.hasSeenOnboarding ?? false;

  final PrefsStore? _store;
  ThemeMode _themeMode;
  String _languageCode;
  bool _hasSeenOnboarding;

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get isVietnamese => _languageCode == 'vi';
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  Locale get locale => Locale(_languageCode);

  Map<String, String> get _strings => isVietnamese ? Vi.strings : En.strings;

  String t(String key) => _strings[key] ?? Vi.strings[key] ?? key;

  Future<void> completeOnboarding() async {
    if (_hasSeenOnboarding) return;
    _hasSeenOnboarding = true;
    notifyListeners();
    if (_store != null) {
      await _store.setOnboardingSeen(true);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_seen', true);
    }
  }

  Future<void> resetOnboarding() async {
    if (!_hasSeenOnboarding) return;
    _hasSeenOnboarding = false;
    notifyListeners();
    if (_store != null) {
      await _store.setOnboardingSeen(false);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_seen', false);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _store?.setThemeMode(mode);
  }

  Future<void> toggleDarkMode(bool dark) =>
      setThemeMode(dark ? ThemeMode.dark : ThemeMode.light);

  Future<void> setLanguage(String code) async {
    if (code == _languageCode || (code != 'vi' && code != 'en')) return;
    _languageCode = code;
    notifyListeners();
    await _store?.setLanguageCode(code);
  }
}
