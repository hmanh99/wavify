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
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_event.dart';
import '../bloc/favorite_state.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
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
        _readFavoriteBloc(
          context,
        )?.add(CheckFavoritePlaylistsRequested([widget.playlistId]));
      }
    });
  }

  FavoriteBloc? _readFavoriteBloc(BuildContext context) {
    try {
      return context.read<FavoriteBloc>();
    } catch (_) {
      return sl.isRegistered<FavoriteBloc>() ? sl<FavoriteBloc>() : null;
    }
  }

  FavoriteBloc? _watchFavoriteBloc(BuildContext context) {
    try {
      return context.watch<FavoriteBloc>();
    } catch (_) {
      return sl.isRegistered<FavoriteBloc>() ? sl<FavoriteBloc>() : null;
    }
  }

  String? _resolveCurrentUserId(BuildContext context) {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user != null) {
        return authState.user!.id;
      }
    } catch (_) {}
    try {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        return profileState.profile.id;
      }
    } catch (_) {}
    return null;
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
    final favBloc = _watchFavoriteBloc(context);
    final favState = favBloc?.state ?? const FavoriteState();
    final currentUserId = _resolveCurrentUserId(context);

    return BlocConsumer<PlaylistBloc, PlaylistState>(
      listener: (context, state) {
        if (state.selectedPlaylist?.id == widget.playlistId &&
            state.selectedPlaylist!.songs.isNotEmpty) {
          final songIds = state.selectedPlaylist!.songs
              .map((s) => s.id)
              .where((id) => id.isNotEmpty)
              .toList();
          if (songIds.isNotEmpty) {
            _readFavoriteBloc(context)?.add(CheckFavoriteSongsRequested(songIds));
          }
        }
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
        final isPlaylistFav = favState.isPlaylistFavorite(playlist.id);
        final isOwner =
            currentUserId == null ||
            playlist.ownerId == null ||
            playlist.ownerId == currentUserId;

        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          appBar: AppTopBar(
            actions: [
              if (favBloc != null)
                IconButton(
                  icon: Icon(
                    isPlaylistFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isPlaylistFav
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                  tooltip: isPlaylistFav
                      ? context.l10n.removeFromFavorites
                      : context.l10n.addToFavorites,
                  onPressed: () {
                    favBloc.add(
                      ToggleFavoritePlaylistRequested(
                        playlistId: playlist.id,
                        playlist: playlist,
                      ),
                    );
                  },
                ),
              if (isOwner) ...[
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
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.lg,
                            AppSpacing.md,
                          ),
                          child: Column(
                            children: [
                              AppCard(
                                showBorder: true,
                                borderRadius: AppRadius.lg,
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Column(
                                  children: [
                                    Center(
                                      child: MusicArtwork(
                                        imageUrl: playlist.displayCoverUrl,
                                        title: playlist.name,
                                        width: 140,
                                        height: 140,
                                        borderRadius: AppRadius.lg,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
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
                                          horizontal: AppSpacing.sm,
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
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: AppSpacing.sm,
                                      runSpacing: AppSpacing.xs,
                                      children: [
                                        Text(
                                          '${context.l10n.tracksCount(songs.length)} • $durationText',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: appColors.textMuted,
                                            fontWeight: FontWeight.w600,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
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
                                              AppRadius.xs,
                                            ),
                                            border: Border.all(
                                              color: appColors.subtleBorder,
                                            ),
                                          ),
                                          child: Text(
                                            playlist.isPublic
                                                ? context.l10n.public
                                                : context.l10n.private,
                                            style: textTheme.labelSmall
                                                ?.copyWith(
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
                                            onPressed: () =>
                                                _onPlayAll(playlist),
                                          ),
                                        ),
                                        if (isOwner) ...[
                                          const SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: AppPrimaryButton(
                                              text: context.l10n.addSongs,
                                              icon: Icons.add_rounded,
                                              isSecondary: true,
                                              onPressed: () =>
                                                  _showAddSongsBottomSheet(
                                                    context,
                                                    playlist,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (_isReorderMode) ...[
                                const SizedBox(height: AppSpacing.md),
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
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.xxl,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: AppCard(
                              showBorder: true,
                              borderRadius: AppRadius.lg,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
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
                                  return Container(
                                    key: ValueKey(song.id),
                                    decoration: BoxDecoration(
                                      border: index < songs.length - 1
                                          ? Border(
                                              bottom: BorderSide(
                                                color: appColors.subtleBorder,
                                                width: 1,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                        onTap: _isReorderMode
                                            ? null
                                            : () => _onPlayAll(
                                                playlist,
                                                initialIndex: index,
                                              ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: AppSpacing.sm + 2,
                                          ),
                                          child: Row(
                                            children: [
                                              if (_isReorderMode)
                                                ReorderableDragStartListener(
                                                  index: index,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: AppSpacing.md,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .drag_indicator_rounded,
                                                      color:
                                                          appColors.textMuted,
                                                      size: 22,
                                                    ),
                                                  ),
                                                )
                                              else
                                                SizedBox(
                                                  width: 26,
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: textTheme.bodySmall
                                                        ?.copyWith(
                                                          color: appColors
                                                              .textMuted,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFeatures: const [
                                                            FontFeature
                                                                .tabularFigures(),
                                                          ],
                                                        ),
                                                  ),
                                                ),
                                              MusicArtwork(
                                                imageUrl: song.coverUrl,
                                                title: song.title,
                                                artist: song.artist,
                                                width: 44,
                                                height: 44,
                                                borderRadius: AppRadius.sm,
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.md,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      song.title,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          textTheme.titleMedium,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${song.artist} • ${AppFormatters.durationSeconds(song.durationSec)}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: textTheme.bodySmall
                                                          ?.copyWith(
                                                            color: appColors
                                                                .textMuted,
                                                            fontFeatures: const [
                                                              FontFeature
                                                                  .tabularFigures(),
                                                            ],
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (favBloc != null)
                                                IconButton(
                                                  icon: Icon(
                                                    favState.isSongFavorite(
                                                            song.id)
                                                        ? Icons.favorite_rounded
                                                        : Icons
                                                            .favorite_border_rounded,
                                                    color:
                                                        favState.isSongFavorite(
                                                      song.id,
                                                    )
                                                        ? colorScheme.primary
                                                        : appColors.textMuted,
                                                    size: 20,
                                                  ),
                                                  tooltip:
                                                      favState.isSongFavorite(
                                                              song.id)
                                                      ? context
                                                            .l10n
                                                            .removeFromFavorites
                                                      : context
                                                            .l10n
                                                            .addToFavorites,
                                                  onPressed: () {
                                                    favBloc.add(
                                                      ToggleFavoriteSongRequested(
                                                        songId: song.id,
                                                        song: song,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              if (isOwner)
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.close_rounded,
                                                    color: appColors.textMuted,
                                                    size: 20,
                                                  ),
                                                  tooltip: context
                                                      .l10n
                                                      .removeFromPlaylist,
                                                  onPressed: () {
                                                    context
                                                        .read<PlaylistBloc>()
                                                        .add(
                                                          RemoveSongFromPlaylistRequested(
                                                            playlistId:
                                                                playlist.id,
                                                            songId: song.id,
                                                          ),
                                                        );
                                                  },
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
