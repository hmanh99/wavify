import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
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
        const SizedBox(height: AppSpacing.md + 2),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < songs.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.lg),
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

    return Semantics(
      button: true,
      label: '${song.title}, ${song.artist}',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MusicArtwork(
                imageUrl: song.coverUrl,
                title: song.title,
                artist: song.artist,
                width: 120,
                height: 120,
                borderRadius: AppRadius.lg,
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
                style: textTheme.bodySmall?.copyWith(
                  color: appColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
