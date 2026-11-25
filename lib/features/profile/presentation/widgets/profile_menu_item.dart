import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appColors = context.appColors;
    final textTheme = context.textTheme;

    final iconColor = isDestructive ? colorScheme.error : colorScheme.primary;
    final iconBg = isDestructive
        ? colorScheme.error.withValues(alpha: 0.12)
        : appColors.inputFill;
    final iconBorder = isDestructive
        ? colorScheme.error.withValues(alpha: 0.28)
        : appColors.subtleBorder;
    final titleColor = isDestructive
        ? colorScheme.error
        : colorScheme.onSurface;
    final highlight = colorScheme.onSurface.withValues(alpha: 0.05);

    return Semantics(
      button: true,
      label: subtitle != null ? '$title, $subtitle' : title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          highlightColor: highlight,
          splashColor: highlight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md + 2,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: iconBorder, width: 1),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          color: titleColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: appColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (!isDestructive)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: appColors.textMuted,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
