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

  static const ColorFilter _grayscaleFilter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final minHeaderHeight = (screenHeight * 0.34).clamp(200.0, 310.0);
    final appColors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: appColors.subtleBorder, width: 1),
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: double.infinity,
          minHeight: minHeaderHeight,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: _grayscaleFilter,
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(color: ColorsConstant.black),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(color: const Color(0xCC0B0B0C)),
            ),
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
                            backgroundColor: const Color(0x990B0B0C),
                            foregroundColor: ColorsConstant.white,
                            side: BorderSide(
                              color: ColorsConstant.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ] else
                        SizedBox(
                          height: (minHeaderHeight * 0.28).clamp(40.0, 96.0),
                        ),
                      Text(
                        context.l10n.appTitle.toUpperCase(),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFFD4D3CE),
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      Text(
                        title,
                        style: context.textTheme.headlineLarge?.copyWith(
                          color: ColorsConstant.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      Text(
                        subtitle,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFD4D3CE),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
