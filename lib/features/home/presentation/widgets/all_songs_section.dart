import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../domain/entities/song_entity.dart';

class AllSongsSection extends StatelessWidget {
  final List<SongEntity> songs;
  final ValueChanged<SongEntity> onSongTap;
  final void Function(SongEntity song)? onAddToPlaylist;
  final bool isSearching;

  const AllSongsSection({
    super.key,
    required this.songs,
    required this.onSongTap,
    this.onAddToPlaylist,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final appColors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                isSearching
                    ? context.l10n.searchResults(songs.length)
                    : context.l10n.allSongsWithCount(songs.length),
                style: textTheme.titleLarge,
              ),
              if (!isSearching && songs.isNotEmpty)
                Text(
                  context.l10n.readyToPlay,
                  style: textTheme.bodySmall?.copyWith(
                    color: appColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md + 2),
        if (songs.isEmpty)
          _buildEmptyState(context)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: songs.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.sm + 2),
            itemBuilder: (context, index) {
              final song = songs[index];
              final metaParts = <String>[
                if (song.album != null && song.album!.isNotEmpty) song.album!,
                AppFormatters.durationSeconds(song.durationSec),
              ];

              return AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                onTap: () => onSongTap(song),
                semanticLabel: '${song.title}, ${song.artist}',
                child: Row(
                  children: [
                    MusicArtwork(
                      imageUrl: song.coverUrl,
                      title: song.title,
                      artist: song.artist,
                      width: 56,
                      height: 56,
                      borderRadius: AppRadius.md,
                    ),
                    const SizedBox(width: AppSpacing.md + 2),
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
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: appColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            metaParts.join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: appColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onAddToPlaylist != null)
                      IconButton(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: appColors.textMuted,
                          size: 20,
                        ),
                        tooltip: context.l10n.addToPlaylist,
                        onPressed: () => onAddToPlaylist!(song),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: context.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (isSearching) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: context.l10n.noSongsFound,
        description: context.l10n.noSongsFoundDesc,
      );
    }

    return AppEmptyState(
      icon: Icons.music_note_rounded,
      title: context.l10n.noSongsOnServer,
      description: context.l10n.noSongsOnServerDesc,
      actionLabel: context.l10n.uploadNow,
      actionIcon: Icons.cloud_upload_outlined,
      onAction: () => context.go(AppRouter.upload),
    );
  }
}
