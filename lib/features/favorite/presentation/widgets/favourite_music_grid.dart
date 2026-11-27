import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../data/models/song_model.dart';
import '../../domain/entities/song_entity.dart';
import '../bloc/playlist_bloc.dart';
import 'add_to_playlist_bottom_sheet.dart';

class FavouriteMusicGrid extends StatelessWidget {
  static const int maxPreviewItems = 3;

  final List<SongModel> songs;
  final ValueChanged<SongModel> onSongTap;
  final ValueChanged<SongModel>? onToggleFavorite;
  final VoidCallback? onSeeMoreTap;

  const FavouriteMusicGrid({
    super.key,
    required this.songs,
    required this.onSongTap,
    this.onToggleFavorite,
    this.onSeeMoreTap,
  });

  void _openAddToPlaylist(BuildContext context, SongModel song) {
    try {
      context.read<PlaylistBloc>();
    } catch (_) {
      return;
    }
    AddToPlaylistBottomSheet.show(
      context,
      SongEntity(
        id: song.id,
        title: song.title,
        artist: song.artist,
        fileUrl: song.fileUrl ?? '',
        coverUrl: song.coverUrl,
        album: song.album,
        durationSec: song.duration.inSeconds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1.0).clamp(1.0, 2.5);
    final visibleSongs = songs.take(maxPreviewItems).toList();
    final hasMore = songs.length > maxPreviewItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.favoriteSongs, style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md + 2),
        if (songs.isEmpty)
          AppEmptyState(
            icon: Icons.favorite_border_rounded,
            title: context.l10n.noFavoriteSongs,
            description: context.l10n.noFavoriteSongsDesc,
          )
        else ...[
          LayoutBuilder(
            builder: (context, constraints) {
              final int crossAxisCount = constraints.maxWidth > 720
                  ? 5
                  : constraints.maxWidth > 500
                  ? 4
                  : constraints.maxWidth > 320
                  ? 3
                  : 2;

              const spacing = AppSpacing.md;
              final tileWidth =
                  (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                  crossAxisCount;
              final textBlockHeight = 20.0 + (40.0 * textScale);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleSongs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: AppSpacing.md + 2,
                  mainAxisExtent: tileWidth + textBlockHeight,
                ),
                itemBuilder: (context, index) {
                  final song = visibleSongs[index];
                  return AppCard(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    borderRadius: AppRadius.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            children: [
                              Semantics(
                                button: true,
                                label: '${song.title}, ${song.artist}',
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  onTap: () => onSongTap(song),
                                  onLongPress: () =>
                                      _openAddToPlaylist(context, song),
                                  child: MusicArtwork(
                                    imageUrl: song.coverUrl,
                                    title: song.title,
                                    artist: song.artist,
                                    width: double.infinity,
                                    height: double.infinity,
                                    borderRadius: AppRadius.md,
                                  ),
                                ),
                              ),
                              if (onToggleFavorite != null)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface.withValues(
                                        alpha: 0.90,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: appColors.subtleBorder,
                                      ),
                                    ),
                                    child: IconButton(
                                      tooltip: song.isFavourite
                                          ? context.l10n.removeFromFavorites
                                          : context.l10n.addToFavorites,
                                      icon: Icon(
                                        song.isFavourite
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: song.isFavourite
                                            ? colorScheme.primary
                                            : appColors.textMuted,
                                        size: 18,
                                      ),
                                      onPressed: () => onToggleFavorite!(song),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs + 2),
                        InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          onTap: () => onSongTap(song),
                          onLongPress: () => _openAddToPlaylist(context, song),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface,
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
                      ],
                    ),
                  );
                },
              );
            },
          ),
          if (hasMore && onSeeMoreTap != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: onSeeMoreTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: appColors.cardSurface,
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: appColors.subtleBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      context.l10n.seeMore,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}
