import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/services/playback_bridge.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../domain/entities/song_entity.dart';
import '../bloc/upload_bloc.dart';
import '../bloc/upload_event.dart';
import 'edit_song_dialog.dart';

class MySongsListView extends StatelessWidget {
  final List<SongEntity> songs;
  final bool isLoading;

  const MySongsListView({
    super.key,
    required this.songs,
    this.isLoading = false,
  });

  void _confirmDelete(BuildContext context, SongEntity song) {
    AppConfirmDialog.show(
      context,
      icon: Icons.delete_outline_rounded,
      title: context.l10n.deleteSong,
      message: context.l10n.deleteSongConfirm(song.title),
      confirmLabel: context.l10n.delete,
      isDestructive: true,
      onConfirm: () {
        context.read<UploadBloc>().add(DeleteSongRequested(song.id));
      },
    );
  }

  void _onPlaySong(BuildContext context, SongEntity song) {
    final playbackItems = songs
        .map((s) => s.toSongModel().toPlaybackMap())
        .toList();
    final index = songs.indexWhere((s) => s.id == song.id);
    final targetIndex = index >= 0 ? index : 0;

    if (sl.isRegistered<PlaybackBridge>()) {
      sl<PlaybackBridge>().playPlaylist(
        playbackItems,
        initialIndex: targetIndex,
      );
    }

    context.go('/listen');
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    if (isLoading && songs.isEmpty) {
      return AppSkeletonPulse(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, _) =>
              const AppSkeletonBox(height: 76, borderRadius: AppRadius.lg),
        ),
      );
    }

    if (songs.isEmpty) {
      return AppEmptyState(
        inCard: false,
        icon: Icons.library_music_rounded,
        title: context.l10n.noUploadedSongs,
        description: context.l10n.noUploadedSongsDesc,
      );
    }

    return RefreshIndicator(
      color: colorScheme.primary,
      backgroundColor: appColors.cardSurface,
      onRefresh: () async {
        context.read<UploadBloc>().add(const LoadMySongsRequested());
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: songs.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final song = songs[index];
          return AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            onTap: () => _onPlaySong(context, song),
            semanticLabel: '${song.title}, ${song.artist}',
            child: Row(
              children: [
                MusicArtwork(
                  imageUrl: song.coverUrl,
                  title: song.title,
                  artist: song.artist,
                  width: 54,
                  height: 54,
                  borderRadius: AppRadius.sm + 2,
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
                      const SizedBox(height: AppSpacing.xs + 2),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: appColors.inputFill,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              song.isPublic
                                  ? context.l10n.public
                                  : context.l10n.private,
                              style: textTheme.labelSmall?.copyWith(
                                color: song.isPublic
                                    ? colorScheme.primary
                                    : appColors.textMuted,
                              ),
                            ),
                          ),
                          if (song.durationSec > 0)
                            Text(
                              AppFormatters.durationSeconds(song.durationSec),
                              style: textTheme.bodySmall?.copyWith(
                                color: appColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: context.l10n.editSong,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: appColors.textMuted,
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      EditSongDialog.show(context, song);
                    } else if (value == 'delete') {
                      _confirmDelete(context, song);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: colorScheme.onSurface,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(context.l10n.editSong),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            context.l10n.deleteSong,
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
