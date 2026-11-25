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

class RecommendSongsSection extends StatelessWidget {
  final List<SongEntity> songs;
  final ValueChanged<SongEntity> onSongTap;
  final void Function(SongEntity song)? onAddToPlaylist;
  final void Function(SongEntity song)? onToggleFavorite;
  final VoidCallback? onShuffle;
  final Set<String> favoriteSongIds;
  final bool isSearching;

  const RecommendSongsSection({
    super.key,
    required this.songs,
    required this.onSongTap,
    this.onAddToPlaylist,
    this.onToggleFavorite,
    this.onShuffle,
    this.favoriteSongIds = const {},
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final appColors = context.appColors;
    final showInlineDuration = MediaQuery.sizeOf(context).width >= 380;
    final visibleSongs = isSearching ? songs : songs.take(5).toList();

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
                    : context.l10n.recommendedSongs,
                style: textTheme.titleLarge,
              ),
              if (!isSearching && songs.length > 1 && onShuffle != null)
                TextButton.icon(
                  onPressed: onShuffle,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                  ),
                  icon: Icon(
                    Icons.shuffle_rounded,
                    size: 16,
                    color: context.colorScheme.primary,
                  ),
                  label: Text(
                    context.l10n.shuffleRecommendations,
                    style: textTheme.labelLarge?.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (songs.isEmpty)
          _buildEmptyState(context)
        else
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
              itemCount: visibleSongs.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, thickness: 1, color: appColors.subtleBorder),
              itemBuilder: (context, index) {
                final song = visibleSongs[index];
                final subtitleParts = <String>[
                  song.artist,
                  if (song.album != null && song.album!.isNotEmpty) song.album!,
                  if (!showInlineDuration && song.durationSec > 0)
                    AppFormatters.durationSeconds(song.durationSec),
                ];

                return Semantics(
                  button: true,
                  label: '${song.title}, ${song.artist}',
                  child: Material(
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
                                    subtitleParts.join(' • '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: appColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (showInlineDuration && song.durationSec > 0) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                AppFormatters.durationSeconds(song.durationSec),
                                style: textTheme.bodySmall?.copyWith(
                                  color: appColors.textMuted,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                            if (onToggleFavorite != null)
                              IconButton(
                                icon: Icon(
                                  favoriteSongIds.contains(song.id)
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: favoriteSongIds.contains(song.id)
                                      ? context.colorScheme.primary
                                      : appColors.textMuted,
                                  size: 20,
                                ),
                                tooltip: favoriteSongIds.contains(song.id)
                                    ? context.l10n.removeFromFavorites
                                    : context.l10n.addToFavorites,
                                onPressed: () => onToggleFavorite!(song),
                              ),
                            if (onAddToPlaylist != null)
                              IconButton(
                                icon: Icon(
                                  Icons.more_horiz_rounded,
                                  color: appColors.textMuted,
                                  size: 20,
                                ),
                                tooltip: context.l10n.addToPlaylist,
                                onPressed: () => onAddToPlaylist!(song),
                              )
                            else if (onToggleFavorite == null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.sm,
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: context.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
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
