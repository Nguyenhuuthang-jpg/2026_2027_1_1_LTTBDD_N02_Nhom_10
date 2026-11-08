import 'package:flutter/material.dart';

import '../core/l10n/app_strings.dart';

/// Hộp thoại xác nhận. Trả về true nếu người dùng đồng ý.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      destructive: destructive,
    ),
  );
  return result ?? false;
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.destructive = false,
  });

  final String title;
  final String message;
  final String? confirmLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.tr('cancel')),
        ),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: error) : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel ?? context.tr('confirm')),
        ),
      ],
    );
  }
}
