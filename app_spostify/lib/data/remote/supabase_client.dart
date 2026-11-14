import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  AppSupabase._();

  static const String url = 'https://htzmhtjhgefdkmjsugky.supabase.co';
  static const String publishableKey =
      'sb_publishable_yhUAnd0MYkEcFWfNCkGF8w_8m_mSDqS';

  @Deprecated('Use publishableKey instead.')
  static const String anonKey = publishableKey;

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) {
      throw StateError('Thiếu Supabase URL hoặc publishable key.');
    }
    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
