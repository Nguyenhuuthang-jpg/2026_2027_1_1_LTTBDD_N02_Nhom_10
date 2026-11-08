import 'package:flutter/material.dart';

import 'app.dart';
import 'data/local/prefs_store.dart';
import 'data/remote/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppSupabase.isConfigured) {
    runApp(const SupabaseSetupRequiredApp());
    return;
  }

  try {
    await AppSupabase.initialize();
  } catch (error, stackTrace) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'Giai Điệu startup',
      context: ErrorDescription('while initializing Supabase'),
    ));
    runApp(SupabaseSetupRequiredApp(error: error));
    return;
  }

  // Cài đặt (ngôn ngữ, sáng/tối) + cache. Lỗi ở đây không được chặn app chạy.
  PrefsStore? prefs;
  try {
    prefs = await PrefsStore.create();
  } catch (error) {
    debugPrint('Không mở được shared_preferences: $error');
  }

  runApp(GiaiDieuApp(prefs: prefs));
}
