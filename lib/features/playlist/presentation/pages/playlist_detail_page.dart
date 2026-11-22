import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/playback_bridge.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../domain/entities/playlist_entity.dart';
import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';
import '../bloc/playlist_state.dart';
import '../widgets/add_multiple_songs_bottom_sheet.dart';
import '../widgets/create_edit_playlist_dialog.dart';

class PlaylistDetailPage extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailPage({super.key, required this.playlistId});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  bool _isReorderMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlaylistBloc>().add(
          LoadPlaylistDetailRequested(widget.playlistId),
        );
      }
    });
  }

  void _onPlayAll(PlaylistEntity playlist, {int initialIndex = 0}) {
    if (playlist.songs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.playlistEmptyToPlay)));
      return;
    }

    final playbackItems = playlist.songs
        .map((s) => s.toSongModel().toPlaybackMap())
        .toList();
    final index = initialIndex.clamp(0, playbackItems.length - 1);

    if (sl.isRegistered<PlaybackBridge>()) {
      sl<PlaybackBridge>().playPlaylist(playbackItems, initialIndex: index);
    }

    context.go(AppRouter.listen);
  }

  void _showDeleteConfirmDialog(BuildContext context, PlaylistEntity playlist) {
    AppConfirmDialog.show(
      context,
      icon: Icons.delete_outline_rounded,
      title: context.l10n.deletePlaylist,
      message: context.l10n.deletePlaylistConfirm(playlist.name),
      confirmLabel: context.l10n.delete,
      isDestructive: true,
      onConfirm: () {
        context.read<PlaylistBloc>().add(DeletePlaylistRequested(playlist.id));
        Navigator.of(context).pop();
      },
    );
  }

  void _showAddSongsBottomSheet(BuildContext context, PlaylistEntity playlist) {
    AddMultipleSongsBottomSheet.show(context, playlist);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return BlocConsumer<PlaylistBloc, PlaylistState>(
      listener: (context, state) {
        if (state.status == PlaylistStatus.success && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message!,
                style: TextStyle(color: appColors.onSuccess),
              ),
              backgroundColor: appColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state.status == PlaylistStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
                style: TextStyle(color: colorScheme.onError),
              ),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        PlaylistEntity? playlist =
            state.selectedPlaylist?.id == widget.playlistId
            ? state.selectedPlaylist
            : state.playlists.cast<PlaylistEntity?>().firstWhere(
                (p) => p?.id == widget.playlistId,
                orElse: () => null,
              );

        if (state.isLoading && playlist == null) {
          return Scaffold(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            appBar: const AppTopBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (playlist == null) {
          return Scaffold(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            appBar: const AppTopBar(),
            body: AppEmptyState(
              inCard: false,
              icon: Icons.music_off_rounded,
              title: context.l10n.playlistNotFound,
              actionLabel: context.l10n.goBack,
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }

        final songs = playlist.songs;
        final totalSecs = songs.fold<int>(0, (sum, s) => sum + s.durationSec);
        final durationText = context.l10n.minutesSeconds(
          totalSecs ~/ 60,
          totalSecs % 60,
        );

        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          appBar: AppTopBar(
            actions: [
              IconButton(
                icon: Icon(
                  _isReorderMode
                      ? Icons.check_circle_rounded
                      : Icons.swap_vert_rounded,
                  color: _isReorderMode
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
                tooltip: _isReorderMode
                    ? context.l10n.doneReordering
                    : context.l10n.reorderSongs,
                onPressed: () {
                  setState(() => _isReorderMode = !_isReorderMode);
                },
              ),
              PopupMenuButton<String>(
                tooltip: context.l10n.editPlaylist,
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: colorScheme.onSurface,
                ),
                onSelected: (val) {
                  if (val == 'edit') {
                    CreateEditPlaylistDialog.show(context, playlist: playlist);
                  } else if (val == 'delete') {
                    _showDeleteConfirmDialog(context, playlist);
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
                        const SizedBox(width: AppSpacing.sm + 2),
                        Text(context.l10n.editPlaylist),
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
                        const SizedBox(width: AppSpacing.sm + 2),
                        Text(
                          context.l10n.deletePlaylist,
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: colorScheme.primary,
              backgroundColor: appColors.cardSurface,
              onRefresh: () async {
                context.read<PlaylistBloc>().add(
                  LoadPlaylistDetailRequested(widget.playlistId),
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg + AppSpacing.xs,
                            vertical: AppSpacing.sm + 2,
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: MusicArtwork(
                                  imageUrl: playlist.displayCoverUrl,
                                  title: playlist.name,
                                  width: 156,
                                  height: 156,
                                  borderRadius: AppRadius.xl,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg + 2),
                              Text(
                                playlist.name,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineSmall,
                              ),
                              if (playlist.description != null &&
                                  playlist.description!.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs + 2),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                  ),
                                  child: Text(
                                    playlist.description!,
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: appColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  Text(
                                    '${context.l10n.tracksCount(songs.length)} • $durationText',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: appColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: appColors.inputFill,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.hundred,
                                      ),
                                    ),
                                    child: Text(
                                      playlist.isPublic
                                          ? context.l10n.public
                                          : context.l10n.private,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppPrimaryButton(
                                      text: context.l10n.playAll,
                                      icon: Icons.play_arrow_rounded,
                                      onPressed: () => _onPlayAll(playlist),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: AppPrimaryButton(
                                      text: context.l10n.addSongs,
                                      icon: Icons.add_rounded,
                                      isSecondary: true,
                                      onPressed: () => _showAddSongsBottomSheet(
                                        context,
                                        playlist,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_isReorderMode) ...[
                                const SizedBox(height: AppSpacing.lg),
                                AppCard(
                                  showBorder: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md + 2,
                                    vertical: AppSpacing.sm,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: colorScheme.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          context.l10n.reorderDragHint,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.md),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (songs.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyState(
                        inCard: false,
                        icon: Icons.queue_music_rounded,
                        title: context.l10n.emptyPlaylist,
                        description: context.l10n.emptyPlaylistHint,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg + AppSpacing.xs,
                        0,
                        AppSpacing.lg + AppSpacing.xs,
                        AppSpacing.xxl,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              buildDefaultDragHandles: _isReorderMode,
                              itemCount: songs.length,
                              onReorder: (oldIndex, newIndex) {
                                context.read<PlaylistBloc>().add(
                                  ReorderPlaylistSongsRequested(
                                    playlistId: playlist.id,
                                    oldIndex: oldIndex,
                                    newIndex: newIndex,
                                  ),
                                );
                              },
                              itemBuilder: (context, index) {
                                final song = songs[index];
                                return Padding(
                                  key: ValueKey(song.id),
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm + 2,
                                  ),
                                  child: AppCard(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm,
                                    ),
                                    onTap: _isReorderMode
                                        ? null
                                        : () => _onPlayAll(
                                            playlist,
                                            initialIndex: index,
                                          ),
                                    child: Row(
                                      children: [
                                        if (_isReorderMode)
                                          ReorderableDragStartListener(
                                            index: index,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: AppSpacing.md,
                                              ),
                                              child: Icon(
                                                Icons.drag_indicator_rounded,
                                                color: appColors.textMuted,
                                                size: 22,
                                              ),
                                            ),
                                          )
                                        else
                                          SizedBox(
                                            width: 24,
                                            child: Text(
                                              '${index + 1}',
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: appColors.textMuted,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        MusicArtwork(
                                          imageUrl: song.coverUrl,
                                          title: song.title,
                                          artist: song.artist,
                                          width: 48,
                                          height: 48,
                                          borderRadius: AppRadius.md,
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                song.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.titleMedium,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${song.artist} • ${AppFormatters.durationSeconds(song.durationSec)}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          appColors.textMuted,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close_rounded,
                                            color: appColors.textMuted,
                                            size: 20,
                                          ),
                                          tooltip:
                                              context.l10n.removeFromPlaylist,
                                          onPressed: () {
                                            context.read<PlaylistBloc>().add(
                                              RemoveSongFromPlaylistRequested(
                                                playlistId: playlist.id,
                                                songId: song.id,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
