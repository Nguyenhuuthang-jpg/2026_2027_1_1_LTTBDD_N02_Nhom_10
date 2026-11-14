import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';

extension AppStrings on BuildContext {
  String tr(String key) => watch<SettingsProvider>().t(key);

  String trNow(String key) => read<SettingsProvider>().t(key);
}
