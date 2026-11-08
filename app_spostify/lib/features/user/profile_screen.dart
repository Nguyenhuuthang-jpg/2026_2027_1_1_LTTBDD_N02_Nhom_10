import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/settings_sections.dart';
import 'developer_screen.dart';
import 'user_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final users = context.read<UserProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final user = auth.user;
    if (user == null) return;

    final controller = TextEditingController(text: user.name);
    final formKey = GlobalKey<FormState>();
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('editName')),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 60,
            validator: Validators.validateDisplayName,
            decoration: InputDecoration(labelText: context.tr('displayName')),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName == user.name) return;

    final updated = await users.updateProfile(user.copyWith(name: newName));
    if (updated != null) {
      auth.updateLocalUser(updated);
      messenger.showSnackBar(SnackBar(content: Text(auth.user?.name ?? newName)));
    } else if (users.errorMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(users.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final history = context.watch<HistoryProvider>();
    if (user == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 24),
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppTheme.primaryGreen,
            foregroundImage: (user.avatarUrl?.isNotEmpty ?? false)
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: Text(user.initial,
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkBackground)),
          ),
        ),
        const SizedBox(height: 12),
        Text(user.name,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        Text(user.email,
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _Counter(value: history.favorites.length, label: context.tr('favorites')),
              const SizedBox(width: 12),
              _Counter(value: history.history.length, label: context.tr('history')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(context.tr('editName')),
          onTap: () => _editName(context),
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(context.tr('n_set')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const UserSettingsScreen())),
        ),
        ListTile(
          leading: const Icon(Icons.groups_outlined),
          title: Text(context.tr('developer')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const DeveloperScreen())),
        ),
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

class _Counter extends StatelessWidget {
  const _Counter({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Text('$value',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      );
}
