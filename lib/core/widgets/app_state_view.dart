import 'package:flutter/material.dart';
import '../l10n/app_l10n.dart';
import '../theme/app_tokens.dart';
import 'app_card.dart';
import 'app_primary_button.dart';

/// Unified empty state view with calm iconography and optional action.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool inCard;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.inCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final textTheme = context.textTheme;

    final body = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: appColors.inputFill,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: appColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: appColors.textMuted),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              text: actionLabel!,
              icon: actionIcon,
              width: null,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );

    if (!inCard) {
      return Center(child: body);
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: SizedBox(width: double.infinity, child: body),
    );
  }
}

/// Unified error state view with retry button.
class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final bool inCard;

  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.inCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final appColors = context.appColors;

    final body = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 28,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: appColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            text: context.l10n.retry,
            icon: Icons.refresh_rounded,
            width: null,
            onPressed: onRetry,
          ),
        ],
      ),
    );

    if (!inCard) {
      return Center(child: body);
    }

    return AppCard(
      padding: EdgeInsets.zero,
      showBorder: true,
      child: SizedBox(width: double.infinity, child: body),
    );
  }
}

/// Subtle animated skeleton placeholder for loading lists and horizontal shelves.
class AppSkeletonPulse extends StatefulWidget {
  final Widget child;

  const AppSkeletonPulse({super.key, required this.child});

  @override
  State<AppSkeletonPulse> createState() => _AppSkeletonPulseState();
}

class _AppSkeletonPulseState extends State<AppSkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.45,
        end: 0.9,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

class AppSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const AppSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
