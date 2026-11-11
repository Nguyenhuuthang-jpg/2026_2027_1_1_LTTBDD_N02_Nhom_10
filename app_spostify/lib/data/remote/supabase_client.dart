import 'package:supabase_flutter/supabase_flutter.dart';

/// Điểm truy cập Supabase duy nhất của ứng dụng.
/// Truyền URL và publishable/anon key bằng --dart-define, không đưa service_role
/// key vào ứng dụng Flutter.
class AppSupabase {
  AppSupabase._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  @Deprecated('Use publishableKey instead.')
  static const String anonKey = publishableKey;

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) {
      throw StateError(
        'Thiếu SUPABASE_URL hoặc SUPABASE_PUBLISHABLE_KEY. '
        'Hãy truyền hai giá trị bằng --dart-define.',
      );
    }
    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
