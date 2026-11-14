import 'package:flutter/material.dart';

import '../core/l10n/en.dart';
import '../core/l10n/vi.dart';
import '../data/local/prefs_store.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({PrefsStore? store})
      : _store = store,
        _themeMode = store?.themeMode ?? ThemeMode.dark,
        _languageCode = store?.languageCode ?? 'vi';

  final PrefsStore? _store;
  ThemeMode _themeMode;
  String _languageCode;

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get isVietnamese => _languageCode == 'vi';
  bool get isDark => _themeMode == ThemeMode.dark;
  Locale get locale => Locale(_languageCode);

  Map<String, String> get _strings => isVietnamese ? Vi.strings : En.strings;

  String t(String key) => _strings[key] ?? Vi.strings[key] ?? key;

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
