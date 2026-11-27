import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../data/models/song_model.dart';

class RecentlyPlayedSection extends StatelessWidget {
  final List<SongModel> songs;
  final ValueChanged<SongModel> onSongTap;

  const RecentlyPlayedSection({
    super.key,
    required this.songs,
    required this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.recentSongs, style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < 5; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                _RecentSongTile(
                  song: songs[i],
                  onTap: () => onSongTap(songs[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentSongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const _RecentSongTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final appColors = context.appColors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderRadius: AppRadius.lg,
      onTap: onTap,
      semanticLabel: '${song.title}, ${song.artist}',
      child: SizedBox(
        width: 112,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MusicArtwork(
              imageUrl: song.coverUrl,
              title: song.title,
              artist: song.artist,
              width: 112,
              height: 112,
              borderRadius: AppRadius.md,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(color: appColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
