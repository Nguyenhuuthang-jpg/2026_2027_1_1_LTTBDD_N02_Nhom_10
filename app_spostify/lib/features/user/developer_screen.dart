import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// Thông tin nhóm phát triển. Sửa danh sách [_members] để điền tên và MSSV.
class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  static const List<({String name, String studentId, String role})> _members = [
    (
      name: 'Nguyễn Hữu Thắng',
      studentId: 'MSSV: 24100209',
      role: 'Xác thực, database',
    ),
    (
      name: 'Nguyễn Xuân Thành',
      studentId: 'MSSV: 24100115',
      role: 'Giao diện người dùng',
    ),
    (
      name: 'Kiều Vĩnh Tiến',
      studentId: 'MSSV: 24100240',
      role: 'Giao diện quản trị',
    ),
  ];

  static const List<String> _stack = [
    'Flutter',
    'Provider',
    'Supabase',
    'just_audio',
    'shared_preferences',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('developer'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.graphic_eq_rounded,
                    size: 48,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('appName'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(context.tr('team'), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(
                    '${context.tr('version')} 1.0.0',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final m in _members) ...[
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen,
                  child: Text(
                    m.name.characters.first,
                    style: const TextStyle(
                      color: AppTheme.darkBackground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: Text(
                  m.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${m.studentId} · ${m.role}'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final s in _stack) Chip(label: Text(s))],
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('mem'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
