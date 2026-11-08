import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/local/app_database.dart';
import 'data/local/prefs_store.dart';
import 'features/admin/admin_shell.dart';
import 'features/auth/login_screen.dart';
import 'features/user/user_shell.dart';
import 'providers/auth_provider.dart';
import 'providers/history_provider.dart';
import 'providers/player_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/song_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/user_provider.dart';

class GiaiDieuApp extends StatelessWidget {
  const GiaiDieuApp({super.key, this.prefs});

  /// Có thể null (ví dụ trong test) – khi đó cài đặt không được lưu lại.
  final PrefsStore? prefs;

  @override
  Widget build(BuildContext context) {
    final cache = prefs == null ? null : AppDatabase(prefs!);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(store: prefs)),
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => SongProvider(cache: cache)),
        ChangeNotifierProvider(create: (_) => PlaylistProvider(cache: cache)),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final history = context.read<HistoryProvider>();
            // Mỗi lần bắt đầu phát một bài -> ghi lịch sử + tăng lượt nghe.
            return PlayerProvider()..onSongStarted = history.recordPlay;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Giai Điệu',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

/// Chưa đăng nhập -> LoginScreen; admin -> AdminShell; người dùng -> UserShell.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isInitializing) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = auth.user;
        if (user == null) return const LoginScreen();
        // Key theo id để khi đổi tài khoản, toàn bộ trạng thái shell được tạo lại.
        return user.isAdmin
            ? AdminShell(key: ValueKey('admin-${user.id}'))
            : UserShell(key: ValueKey('user-${user.id}'));
      },
    );
  }
}

/// Màn hình hướng dẫn khi chưa cấu hình khóa kết nối Supabase.
class SupabaseSetupRequiredApp extends StatelessWidget {
  const SupabaseSetupRequiredApp({super.key, this.error});

  /// Lỗi khởi tạo (nếu có) để dễ chẩn đoán.
  final Object? error;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.primaryGreen),
                    const SizedBox(height: 16),
                    const Text('Chưa cấu hình Supabase',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Sao chép env.example.json thành env.json và điền SUPABASE_URL, '
                      'SUPABASE_ANON_KEY (Supabase → Project Settings → API).\n\n'
                      '2. Chạy:\n'
                      'flutter run -d chrome --dart-define-from-file=env.json\n\n'
                      'Hoặc trong VS Code: Run and Debug → chọn "Giai Điệu (Chrome)".',
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Text('Chi tiết lỗi: $error',
                          style: const TextStyle(color: Colors.redAccent)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
