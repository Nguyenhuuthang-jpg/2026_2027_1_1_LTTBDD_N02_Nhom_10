import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../widgets/settings_sections.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('n_set'))),
      body: const SettingsSections(),
    );
  }
}
