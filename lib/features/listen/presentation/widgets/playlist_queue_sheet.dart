import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../data/models/song_model.dart';

class PlaylistQueueSheet extends StatelessWidget {
  final List<SongModel> playlist;
  final int currentIndex;
  final ValueChanged<int> onSelectSong;

  const PlaylistQueueSheet({
    super.key,
    required this.playlist,
    required this.currentIndex,
    required this.onSelectSong,
  });

  static Future<void> show(
    BuildContext context, {
    required List<SongModel> playlist,
    required int currentIndex,
    required ValueChanged<int> onSelectSong,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PlaylistQueueSheet(
        playlist: playlist,
        currentIndex: currentIndex,
        onSelectSong: onSelectSong,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;

    return AppBottomSheetFrame(
      maxHeightFraction: 0.65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.playingQueue,
                  style: textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.tracksCount(playlist.length),
                style: textTheme.bodySmall?.copyWith(
                  color: appColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md + 2),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: playlist.length,
              separatorBuilder: (_, _) =>
                  Divider(color: appColors.subtleBorder, height: AppSpacing.lg),
              itemBuilder: (context, index) {
                final song = playlist[index];
                final isCurrent = index == currentIndex;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  minVerticalPadding: AppSpacing.sm,
                  leading: MusicArtwork(
                    imageUrl: song.coverUrl,
                    title: song.title,
                    artist: song.artist,
                    width: 48,
                    height: 48,
                    borderRadius: AppRadius.sm + 2,
                  ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      color: isCurrent
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: isCurrent
                          ? colorScheme.primary
                          : appColors.textMuted,
                    ),
                  ),
                  trailing: isCurrent
                      ? Icon(
                          Icons.equalizer_rounded,
                          color: colorScheme.primary,
                          size: 22,
                        )
                      : null,
                  onTap: () {
                    onSelectSong(index);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
