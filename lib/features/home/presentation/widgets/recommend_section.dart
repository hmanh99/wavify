import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../data/models/song_model.dart';

class RecommendSection extends StatelessWidget {
  final List<SongModel> songs;
  final ValueChanged<SongModel> onSongTap;

  const RecommendSection({
    super.key,
    required this.songs,
    required this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final appColors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recommend for you', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          showBorder: true,
          borderRadius: AppRadius.lg,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: songs.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, thickness: 1, color: appColors.subtleBorder),
            itemBuilder: (context, index) {
              final song = songs[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () => onSongTap(song),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    child: Row(
                      children: [
                        MusicArtwork(
                          imageUrl: song.coverUrl,
                          title: song.title,
                          artist: song.artist,
                          width: 48,
                          height: 48,
                          borderRadius: AppRadius.sm,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${song.artist} • ${song.streams ?? '100k / streams'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: appColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
