import 'package:flutter/material.dart';
import '../../../../core/constants/colors_constant.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';

class AuthHeader extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  const AuthHeader({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final minHeaderHeight = (screenHeight * 0.36).clamp(210.0, 340.0);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: minHeaderHeight,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: ColorsConstant.black),
            ),
          ),
          Positioned.fill(child: Container(color: ColorsConstant.overlay)),
          SafeArea(
            bottom: false,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg + AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.lg + AppSpacing.xs,
                  AppSpacing.xl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (onBack != null) ...[
                      IconButton(
                        onPressed: onBack,
                        tooltip: context.l10n.goBack,
                        style: IconButton.styleFrom(
                          backgroundColor: ColorsConstant.black.withValues(
                            alpha: 0.45,
                          ),
                          foregroundColor: ColorsConstant.white,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 22),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ] else
                      SizedBox(
                        height: (minHeaderHeight * 0.38).clamp(56.0, 128.0),
                      ),
                    Text(
                      title,
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: ColorsConstant.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      subtitle,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: ColorsConstant.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
