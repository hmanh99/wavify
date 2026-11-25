import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserProfileEntity profile;

  const ProfileHeaderCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    final trimmedName = profile.username.trim();
    final initial = trimmedName.isNotEmpty
        ? trimmedName[0].toUpperCase()
        : null;
    final normalizedRole = profile.role.trim();
    final roleLabel =
        normalizedRole.isEmpty || normalizedRole.toUpperCase() == 'USER'
        ? 'Member'
        : normalizedRole;

    return AppCard(
      showBorder: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: appColors.inputFill,
              border: Border.all(color: appColors.subtleBorder, width: 1),
            ),
            child: Center(
              child: initial != null
                  ? Text(
                      initial,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    )
                  : Icon(
                      Icons.person_outline_rounded,
                      size: 26,
                      color: appColors.textMuted,
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.username,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall,
                ),
                if (profile.email.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: appColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.inputFill,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(color: appColors.subtleBorder),
                  ),
                  child: Text(
                    roleLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
