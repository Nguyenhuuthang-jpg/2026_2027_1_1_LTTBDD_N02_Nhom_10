import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';

/// Cách gọi ngắn gọn trong widget: `context.tr('n_home')`.
/// Widget sẽ tự build lại khi đổi ngôn ngữ.
extension AppStrings on BuildContext {
  String tr(String key) => watch<SettingsProvider>().t(key);

  /// Dùng trong callback (onPressed, ...) nơi không được phép `watch`.
  String trNow(String key) => read<SettingsProvider>().t(key);
}
