import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Unified minimalist bottom sheet container with drag handle, SafeArea,
/// and keyboard-inset protection.
class AppBottomSheetFrame extends StatelessWidget {
  final Widget child;
  final double maxHeightFraction;
  final EdgeInsetsGeometry? padding;

  const AppBottomSheetFrame({
    super.key,
    required this.child,
    this.maxHeightFraction = 0.85,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appColors = context.appColors;
    final bottomInset = mediaQuery.viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * maxHeightFraction,
        ),
        decoration: BoxDecoration(
          color: appColors.cardSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        padding:
            padding ??
            EdgeInsets.fromLTRB(
              AppSpacing.lg + AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.lg + AppSpacing.xs,
              AppSpacing.xl + bottomInset,
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: appColors.subtleBorder,
                  borderRadius: BorderRadius.circular(AppRadius.hundred),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
