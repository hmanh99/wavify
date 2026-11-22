import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

class FavouriteProfileCard extends StatelessWidget {
  final VoidCallback? onBack;
  final String name;
  final String email;
  final String membership;
  final String bio;
  final String avatarUrl;

  const FavouriteProfileCard({
    super.key,
    this.onBack,
    this.name = 'Sarwar Jahan',
    this.email = 'sarwarmusic@gmail.com',
    this.membership = 'Gold Member',
    this.bio = 'Love Music and I am not an Musician .',
    this.avatarUrl =
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
            size: 24,
          ),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Image.network(
                avatarUrl,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 85,
                  height: 85,
                  color: appColors.cardSurface,
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: appColors.textMuted,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: textTheme.bodySmall?.copyWith(
                      color: appColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.inputFill,
                      borderRadius: BorderRadius.circular(AppRadius.hundred),
                    ),
                    child: Text(
                      membership,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    bio,
                    style: textTheme.bodySmall?.copyWith(
                      color: appColors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
