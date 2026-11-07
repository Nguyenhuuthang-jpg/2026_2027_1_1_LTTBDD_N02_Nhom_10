import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'models/app_user.dart';
import 'providers/auth_provider.dart';
import 'providers/player_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/song_provider.dart';

class GiaiDieuApp extends StatelessWidget {
  const GiaiDieuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => SongProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: MaterialApp(
        title: 'Giai Điệu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const _AuthGate(),
      ),
    );
  }
}

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
        return _RoleLandingScreen(user: user);
      },
    );
  }
}

/// Điểm rẽ nhánh đầu tiên. Các màn dashboard đầy đủ thuộc phần việc UI riêng.
class _RoleLandingScreen extends StatelessWidget {
  const _RoleLandingScreen({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == UserRole.admin;
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Khu vực quản trị' : 'Giai Điệu'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => context.read<AuthProvider>().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isAdmin ? Icons.admin_panel_settings : Icons.music_note,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(isAdmin ? 'Xin chào Quản trị viên' : 'Xin chào ${user.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(isAdmin
                  ? 'Đăng nhập thành công với quyền admin.'
                  : 'Đăng nhập thành công với quyền người dùng.'),
              const SizedBox(height: 8),
              Text(user.email),
            ],
          ),
        ),
      ),
    );
  }
}

/// Màn hình hướng dẫn khi chưa cấu hình khóa kết nối Supabase.
class SupabaseSetupRequiredApp extends StatelessWidget {
  const SupabaseSetupRequiredApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Chưa cấu hình Supabase. Hãy chạy ứng dụng với '
                '--dart-define=SUPABASE_URL=... và '
                '--dart-define=SUPABASE_ANON_KEY=...',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
}
