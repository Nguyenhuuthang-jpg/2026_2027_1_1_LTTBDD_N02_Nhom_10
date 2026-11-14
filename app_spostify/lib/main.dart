import 'package:flutter/material.dart';

import 'app.dart';
import 'data/local/local_cache_store.dart';
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
    final prefs = await PrefsStore.create();
    final cache = await LocalCacheStore.create();
    runApp(GiaiDieuApp(prefs: prefs, cache: cache));
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

class SupabaseSetupRequiredApp extends StatelessWidget {
  const SupabaseSetupRequiredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Chưa kết nối được Supabase.\n'
              'Kiểm tra lại URL và key trong supabase_client.dart.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
