import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  AppSupabase._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

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
