import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../data/models/song_model.dart';

class PlayerArtwork extends StatelessWidget {
  final SongModel song;

  const PlayerArtwork({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final textTheme = context.textTheme;
    final appColors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth * 0.78
            : screenSize.shortestSide * 0.72;
        final maxHeight = screenSize.height * 0.38;
        final size = math.min(maxWidth, maxHeight).clamp(160.0, 320.0);

        return Column(
          children: [
            MusicArtwork(
              imageUrl: song.coverUrl,
              title: song.title,
              artist: song.artist,
              width: size,
              height: size,
              borderRadius: AppRadius.xl,
              showBadge: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                song.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                song.artist,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: appColors.textMuted,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
