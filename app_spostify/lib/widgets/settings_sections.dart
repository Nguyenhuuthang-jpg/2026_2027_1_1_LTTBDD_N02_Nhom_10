import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/user/developer_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import 'confirm_dialog.dart';

/// Các mục cài đặt dùng chung cho người dùng và admin.
class SettingsSections extends StatelessWidget {
  const SettingsSections({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _Header(context.tr('appearance')),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined),
          title: Text(context.tr('darkMode')),
          value: settings.isDark,
          activeThumbColor: AppTheme.primaryGreen,
          onChanged: settings.toggleDarkMode,
        ),
        _Header(context.tr('lang')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'vi', label: Text('Tiếng Việt')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {settings.languageCode},
            onSelectionChanged: (s) => settings.setLanguage(s.first),
          ),
        ),
        _Header(context.tr('about')),
        ListTile(
          leading: const Icon(Icons.groups_outlined),
          title: Text(context.tr('developer')),
          subtitle: Text(context.tr('team')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DeveloperScreen()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(context.tr('version')),
          trailing: const Text('1.0.0'),
        ),
        const Divider(height: 32),
        ListTile(
          leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
          title: Text(context.tr('logout'),
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          onTap: () => confirmAndSignOut(context),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
        ),
      );
}

/// Hỏi xác nhận, dừng nhạc, xóa dữ liệu người dùng rồi đăng xuất.
Future<void> confirmAndSignOut(BuildContext context) async {
  final ok = await showConfirmDialog(
    context,
    title: context.trNow('logout'),
    message: context.trNow('logoutQ'),
    confirmLabel: context.trNow('logout'),
  );
  if (!ok || !context.mounted) return;
  final player = context.read<PlayerProvider>();
  final history = context.read<HistoryProvider>();
  final auth = context.read<AuthProvider>();
  // Quay về màn gốc trước để AuthGate hiển thị màn đăng nhập.
  Navigator.of(context).popUntil((route) => route.isFirst);
  await player.stop();
  history.reset();
  await auth.signOut();
}
