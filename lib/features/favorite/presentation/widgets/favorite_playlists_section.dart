import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../domain/entities/playlist_entity.dart';

class FavoritePlaylistsSection extends StatelessWidget {
  static const int maxPreviewItems = 3;

  final List<PlaylistEntity> playlists;
  final ValueChanged<PlaylistEntity> onPlaylistTap;
  final ValueChanged<PlaylistEntity>? onToggleFavorite;
  final VoidCallback? onDiscoverTap;
  final VoidCallback? onSeeMoreTap;

  const FavoritePlaylistsSection({
    super.key,
    required this.playlists,
    required this.onPlaylistTap,
    this.onToggleFavorite,
    this.onDiscoverTap,
    this.onSeeMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final appColors = context.appColors;
    final visiblePlaylists = playlists.take(maxPreviewItems).toList();
    final hasMore = playlists.length > maxPreviewItems;

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
              Text(context.l10n.favoritePlaylists, style: textTheme.titleLarge),
              if (onDiscoverTap != null)
                TextButton.icon(
                  onPressed: onDiscoverTap,
                  icon: Icon(
                    Icons.explore_outlined,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                  label: Text(
                    context.l10n.discoverPlaylists,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (playlists.isEmpty)
          AppEmptyState(
            icon: Icons.favorite_border_rounded,
            title: context.l10n.noFavoritePlaylists,
            description: context.l10n.noFavoritePlaylistsDesc,
            actionLabel: onDiscoverTap != null
                ? context.l10n.discoverPlaylists
                : null,
            actionIcon: onDiscoverTap != null ? Icons.explore_outlined : null,
            onAction: onDiscoverTap,
          )
        else ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < visiblePlaylists.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md + 2),
                  _FavoritePlaylistTile(
                    playlist: visiblePlaylists[i],
                    onTap: () => onPlaylistTap(visiblePlaylists[i]),
                    onRemoveFavorite: onToggleFavorite != null
                        ? () => onToggleFavorite!(visiblePlaylists[i])
                        : null,
                  ),
                ],
              ],
            ),
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
                      '${context.l10n.seeMore}',
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

class _FavoritePlaylistTile extends StatelessWidget {
  final PlaylistEntity playlist;
  final VoidCallback onTap;
  final VoidCallback? onRemoveFavorite;

  const _FavoritePlaylistTile({
    required this.playlist,
    required this.onTap,
    this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;

    final subtitle =
        (playlist.ownerName != null && playlist.ownerName!.trim().isNotEmpty)
        ? playlist.ownerName!.trim()
        : (playlist.isPublic ? context.l10n.public : context.l10n.private);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderRadius: AppRadius.lg,
      child: SizedBox(
        width: 124,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Semantics(
                  button: true,
                  label: playlist.name,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: onTap,
                    child: MusicArtwork(
                      imageUrl: playlist.displayCoverUrl,
                      title: playlist.name,
                      artist: subtitle,
                      width: 124,
                      height: 124,
                      borderRadius: AppRadius.md,
                    ),
                  ),
                ),
                if (onRemoveFavorite != null)
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
                        tooltip: context.l10n.removeFromFavorites,
                        icon: Icon(
                          Icons.favorite_rounded,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        onPressed: onRemoveFavorite,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
    );
  }
}
