import 'package:flutter/material.dart';

/// Bảng màu và ThemeData dùng chung cho ứng dụng Giai Điệu.
class AppTheme {
  AppTheme._();

  // Màu tối theo thiết kế: #101412 và xanh chủ đạo #1ED760.
  static const Color darkBackground = Color(0xFF101412);
  static const Color primaryGreen = Color(0xFF1ED760);
  static const Color darkSurface = Color(0xFF1B211D);
  static const Color lightBackground = Color(0xFFF7F9F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF172019);
  static const Color textLight = Color(0xFFF3F7F4);

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        background: darkBackground,
        surface: darkSurface,
        foreground: textLight,
      );

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        background: lightBackground,
        surface: lightSurface,
        foreground: textDark,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color foreground,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: brightness,
      primary: primaryGreen,
      surface: surface,
      onSurface: foreground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: darkBackground,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryGreen,
        selectionColor: Color(0x661ED760),
        selectionHandleColor: primaryGreen,
      ),
    );
  }
}
