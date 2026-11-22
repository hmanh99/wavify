import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../data/models/song_model.dart';
import '../../domain/entities/song_entity.dart';
import '../bloc/playlist_bloc.dart';
import 'add_to_playlist_bottom_sheet.dart';

class FavouriteMusicGrid extends StatelessWidget {
  final List<SongModel> songs;
  final ValueChanged<SongModel> onSongTap;

  const FavouriteMusicGrid({
    super.key,
    required this.songs,
    required this.onSongTap,
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
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1.0).clamp(1.0, 2.5);

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
        else
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
              final textBlockHeight = 14.0 + (38.0 * textScale);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: songs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: AppSpacing.md + 2,
                  mainAxisExtent: tileWidth + textBlockHeight,
                ),
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return Semantics(
                    button: true,
                    label: '${song.title}, ${song.artist}',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md + 2),
                      onTap: () => onSongTap(song),
                      onLongPress: () => _openAddToPlaylist(context, song),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: MusicArtwork(
                              imageUrl: song.coverUrl,
                              title: song.title,
                              artist: song.artist,
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: AppRadius.md + 2,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs + 2),
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
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
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
