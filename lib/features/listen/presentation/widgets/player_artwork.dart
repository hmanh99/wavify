import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../data/models/song_model.dart';

class PlayerArtwork extends StatelessWidget {
  final SongModel song;
  final bool isFavourite;
  final VoidCallback? onFavouriteTap;

  const PlayerArtwork({
    super.key,
    required this.song,
    this.isFavourite = false,
    this.onFavouriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final appColors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth - (AppSpacing.sm * 2)
            : screenSize.shortestSide * 0.72;
        final maxHeight = screenSize.height * 0.34;
        final size = math.min(maxWidth, maxHeight).clamp(150.0, 280.0);

        return Column(
          children: [
            AppCard(
              showBorder: true,
              color: appColors.inputFill,
              borderRadius: AppRadius.xl,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: MusicArtwork(
                imageUrl: song.coverUrl,
                title: song.title,
                artist: song.artist,
                width: size,
                height: size,
                borderRadius: AppRadius.lg,
                showBadge: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: onFavouriteTap != null ? AppSpacing.sm : AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          song.artist,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: appColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onFavouriteTap != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor:
                            isFavourite ? appColors.inputFill : null,
                        side: isFavourite
                            ? BorderSide(
                                color: appColors.subtleBorder,
                                width: 1,
                              )
                            : null,
                      ),
                      tooltip: isFavourite
                          ? context.l10n.removeFromFavorites
                          : context.l10n.addToFavorites,
                      icon: Icon(
                        isFavourite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavourite
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        size: 22,
                      ),
                      onPressed: onFavouriteTap,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
