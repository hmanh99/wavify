import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../domain/entities/song_entity.dart';
import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';
import '../bloc/playlist_state.dart';
import 'create_edit_playlist_dialog.dart';

class AddToPlaylistBottomSheet extends StatelessWidget {
  final SongEntity song;

  const AddToPlaylistBottomSheet({super.key, required this.song});

  static Future<void> show(BuildContext context, SongEntity song) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PlaylistBloc>(),
        child: AddToPlaylistBottomSheet(song: song),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;

    return AppBottomSheetFrame(
      maxHeightFraction: 0.72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MusicArtwork(
                imageUrl: song.coverUrl,
                title: song.title,
                artist: song.artist,
                width: 44,
                height: 44,
                borderRadius: AppRadius.sm + 2,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.addToPlaylist,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${song.title} • ${song.artist}',
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
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: appColors.inputFill,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: appColors.subtleBorder),
              ),
              child: Icon(
                Icons.add_rounded,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            title: Text(
              context.l10n.createNewPlaylist,
              style: textTheme.titleMedium,
            ),
            subtitle: Text(
              context.l10n.createPlaylist,
              style: textTheme.bodySmall?.copyWith(color: appColors.textMuted),
            ),
            onTap: () {
              Navigator.of(context).pop();
              CreateEditPlaylistDialog.show(context);
            },
          ),
          Divider(
            color: appColors.subtleBorder,
            height: AppSpacing.lg + AppSpacing.xs,
          ),
          Expanded(
            child: BlocBuilder<PlaylistBloc, PlaylistState>(
              builder: (context, state) {
                final playlists = state.playlists;

                if (playlists.isEmpty) {
                  return AppEmptyState(
                    inCard: false,
                    icon: Icons.queue_music_rounded,
                    title: context.l10n.noPlaylistsYet,
                    description: context.l10n.noPlaylistsYetDesc,
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: playlists.length,
                  separatorBuilder: (_, _) => Divider(
                    color: appColors.subtleBorder,
                    height: AppSpacing.md,
                  ),
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final alreadyInPlaylist = playlist.songs.any(
                      (s) => s.id == song.id,
                    );

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: MusicArtwork(
                        imageUrl: playlist.displayCoverUrl,
                        title: playlist.name,
                        width: 48,
                        height: 48,
                        borderRadius: AppRadius.md,
                      ),
                      title: Text(
                        playlist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        '${context.l10n.tracksCount(playlist.songCount)} • ${playlist.isPublic ? context.l10n.public : context.l10n.private}',
                        style: textTheme.bodySmall?.copyWith(
                          color: appColors.textMuted,
                        ),
                      ),
                      trailing: Icon(
                        alreadyInPlaylist
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        color: alreadyInPlaylist
                            ? colorScheme.primary
                            : appColors.textMuted,
                        size: 22,
                      ),
                      onTap: () {
                        context.read<PlaylistBloc>().add(
                          AddSongToPlaylistRequested(
                            playlistId: playlist.id,
                            songId: song.id,
                            song: song,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                    );
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
