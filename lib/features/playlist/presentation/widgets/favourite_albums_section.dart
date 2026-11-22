import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../data/models/album_model.dart';

class FavouriteAlbumsSection extends StatelessWidget {
  final List<AlbumModel> albums;
  final ValueChanged<AlbumModel> onAlbumTap;
  final VoidCallback? onCreatePlaylistTap;

  const FavouriteAlbumsSection({
    super.key,
    required this.albums,
    required this.onAlbumTap,
    this.onCreatePlaylistTap,
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
                    onTap: () => onAlbumTap(albums[i]),
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
  final VoidCallback onTap;

  const _AlbumTile({required this.album, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Semantics(
      button: true,
      label: album.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: SizedBox(
          width: 112,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MusicArtwork(
                imageUrl: album.coverUrl,
                title: album.title,
                artist: album.artist,
                width: 112,
                height: 112,
                borderRadius: AppRadius.md + 2,
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                album.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
