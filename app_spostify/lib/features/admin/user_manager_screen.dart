import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/state_views.dart';

/// Quản lý người dùng: tìm kiếm, khóa / mở khóa tài khoản.
class UserManagerScreen extends StatefulWidget {
  const UserManagerScreen({super.key});

  @override
  State<UserManagerScreen> createState() => _UserManagerScreenState();
}

class _UserManagerScreenState extends State<UserManagerScreen> {
  String _query = '';

  Future<void> _toggle(AppUser user) async {
    final provider = context.read<UserProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final msg = context.trNow('t_lock');
    final ok = await showConfirmDialog(
      context,
      title: user.name,
      message: context.trNow(user.isActive ? 'lockQ' : 'unlockQ'),
      confirmLabel: context.trNow(user.isActive ? 'lock' : 'unlock'),
      destructive: user.isActive,
    );
    if (!ok) return;
    final done = await provider.toggleActive(user);
    messenger.showSnackBar(SnackBar(content: Text(done ? msg : provider.errorMessage ?? '')));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final me = context.watch<AuthProvider>().user;
    final q = _query.trim().toLowerCase();
    final users = provider.users
        .where((u) =>
            q.isEmpty || u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: context.tr('searchUsers'),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: provider.isLoading && provider.users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : provider.errorMessage != null && provider.users.isEmpty
                  ? ErrorView(
                      message: provider.errorMessage!,
                      onRetry: () => context.read<UserProvider>().loadUsers(),
                    )
                  : users.isEmpty
                      ? EmptyView(title: context.tr('e_t'), icon: Icons.person_off_outlined)
                      : RefreshIndicator(
                          onRefresh: () => context.read<UserProvider>().loadUsers(),
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, i) {
                              final u = users[i];
                              final canToggle = !u.isAdmin && u.id != me?.id;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: u.isActive
                                      ? AppTheme.primaryGreen
                                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: Text(u.initial,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.darkBackground)),
                                ),
                                title: Text(u.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  '${u.email} · ${context.tr(u.isAdmin ? 'r_admin' : 'r_user')}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: canToggle
                                    ? TextButton.icon(
                                        icon: Icon(u.isActive
                                            ? Icons.lock_open_rounded
                                            : Icons.lock_rounded),
                                        label: Text(
                                            context.tr(u.isActive ? 'active' : 'locked')),
                                        style: TextButton.styleFrom(
                                          foregroundColor: u.isActive
                                              ? AppTheme.primaryGreen
                                              : Theme.of(context).colorScheme.error,
                                        ),
                                        onPressed: () => _toggle(u),
                                      )
                                    : Chip(label: Text(context.tr('r_admin'))),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
