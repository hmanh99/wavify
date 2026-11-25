import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Minimalist elevated surface card with crisp 1px perimeter border,
/// ultra-diffuse ambient separation, and ink ripple.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double borderRadius;
  final bool showBorder;
  final Color? color;
  final String? semanticLabel;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.borderRadius = AppRadius.lg,
    this.showBorder = true,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final radius = BorderRadius.circular(borderRadius);
    final effectiveColor = color ?? appColors.cardSurface;
    final isDark = context.theme.brightness == Brightness.dark;

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: radius,
        border: showBorder
            ? Border.all(color: appColors.subtleBorder, width: 1)
            : null,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      final highlight = context.colorScheme.onSurface.withValues(alpha: 0.05);
      content = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: radius,
        splashFactory: InkRipple.splashFactory,
        highlightColor: highlight,
        splashColor: highlight,
        child: content,
      );
    }

    Widget card = Material(
      color: effectiveColor,
      borderRadius: radius,
      child: content,
    );

    if (effectiveColor.a > 0) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0x28000000)
                  : const Color(0x0C000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: card,
      );
    }

    if (semanticLabel != null) {
      return Semantics(
        button: onTap != null,
        label: semanticLabel,
        child: card,
      );
    }
    return card;
  }
}
