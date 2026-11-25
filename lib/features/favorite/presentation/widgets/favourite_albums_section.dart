import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../data/models/album_model.dart';

class FavouriteAlbumsSection extends StatelessWidget {
  final List<AlbumModel> albums;
  final ValueChanged<AlbumModel> onAlbumTap;
  final VoidCallback? onCreatePlaylistTap;
  final Set<String> favoriteAlbumIds;
  final ValueChanged<AlbumModel>? onToggleFavorite;

  const FavouriteAlbumsSection({
    super.key,
    required this.albums,
    required this.onAlbumTap,
    this.onCreatePlaylistTap,
    this.favoriteAlbumIds = const {},
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

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
              Text(context.l10n.playlists, style: textTheme.titleLarge),
              if (onCreatePlaylistTap != null)
                TextButton.icon(
                  onPressed: onCreatePlaylistTap,
                  icon: Icon(
                    Icons.add_rounded,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                  label: Text(
                    context.l10n.createNew,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (albums.isEmpty)
          AppEmptyState(
            icon: Icons.queue_music_rounded,
            title: context.l10n.noPlaylistsYet,
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < albums.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md + 2),
                  _AlbumTile(
                    album: albums[i],
                    isFavorite: favoriteAlbumIds.contains(albums[i].id),
                    onTap: () => onAlbumTap(albums[i]),
                    onToggleFavorite: onToggleFavorite != null
                        ? () => onToggleFavorite!(albums[i])
                        : null,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _AlbumTile extends StatelessWidget {
  final AlbumModel album;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  const _AlbumTile({
    required this.album,
    this.isFavorite = false,
    required this.onTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final appColors = context.appColors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderRadius: AppRadius.lg,
      child: SizedBox(
        width: 112,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Semantics(
                  button: true,
                  label: album.title,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: onTap,
                    child: MusicArtwork(
                      imageUrl: album.coverUrl,
                      title: album.title,
                      artist: album.artist,
                      width: 112,
                      height: 112,
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
                        color: colorScheme.surface.withValues(alpha: 0.90),
                        shape: BoxShape.circle,
                        border: Border.all(color: appColors.subtleBorder),
                      ),
                      child: IconButton(
                        tooltip: isFavorite
                            ? context.l10n.removeFromFavorites
                            : context.l10n.addToFavorites,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? colorScheme.primary
                              : appColors.textMuted,
                          size: 18,
                        ),
                        onPressed: onToggleFavorite,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: onTap,
              child: Text(
                album.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
