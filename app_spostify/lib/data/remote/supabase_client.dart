import 'package:supabase_flutter/supabase_flutter.dart';

/// Điểm truy cập Supabase duy nhất của ứng dụng.
/// Truyền URL và publishable/anon key bằng --dart-define, không đưa service_role
/// key vào ứng dụng Flutter.
class AppSupabase {
  AppSupabase._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// false nếu chưa truyền khóa hoặc vẫn để giá trị mẫu trong env.example.json.
  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      !url.contains('YOUR_PROJECT') &&
      !anonKey.startsWith('YOUR_');

  static Future<void> initialize() async {
    if (!isConfigured) {
      throw StateError(
        'Thiếu SUPABASE_URL hoặc SUPABASE_ANON_KEY. '
        'Hãy truyền hai giá trị bằng --dart-define.',
      );
    }
    await Supabase.initialize(url: url, publishableKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
