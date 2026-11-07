import 'package:flutter/material.dart';

import 'app.dart';
import 'data/remote/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppSupabase.isConfigured) {
    runApp(const SupabaseSetupRequiredApp());
    return;
  }

  try {
    await AppSupabase.initialize();
    runApp(const GiaiDieuApp());
  } catch (error, stackTrace) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'Giai Điệu startup',
      context: ErrorDescription('while initializing Supabase'),
    ));
    runApp(const SupabaseSetupRequiredApp());
  }
}
