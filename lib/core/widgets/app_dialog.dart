import 'package:flutter/material.dart';
import '../l10n/app_l10n.dart';
import '../theme/app_tokens.dart';

/// Unified minimalist confirmation dialog (supports destructive actions).
class AppConfirmDialog extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const AppConfirmDialog({
    super.key,
    this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    IconData? icon,
    required String title,
    required String message,
    required String confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AppConfirmDialog(
        icon: icon,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final appColors = context.appColors;

    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDestructive ? colorScheme.error : colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(child: Text(title, style: textTheme.titleLarge)),
        ],
      ),
      content: Text(
        message,
        style: textTheme.bodyMedium?.copyWith(color: appColors.textMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            cancelLabel ?? context.l10n.cancel,
            style: TextStyle(color: appColors.textMuted),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive
                ? colorScheme.error
                : colorScheme.primary,
            foregroundColor: isDestructive
                ? colorScheme.onError
                : colorScheme.onPrimary,
            minimumSize: const Size(64, 48),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
