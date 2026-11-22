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

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg + AppSpacing.xs,
        vertical: AppSpacing.xl,
      ),
      borderRadius: AppRadius.xl,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appColors.inputFill,
                border: Border.all(color: appColors.subtleBorder, width: 1),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: appColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              profile.username,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
