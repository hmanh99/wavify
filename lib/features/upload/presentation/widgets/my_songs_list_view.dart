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

class MySongsListView extends StatefulWidget {
  static const int songsPerPage = 20;

  final List<SongEntity> songs;
  final bool isLoading;

  const MySongsListView({
    super.key,
    required this.songs,
    this.isLoading = false,
  });

  @override
  State<MySongsListView> createState() => _MySongsListViewState();
}

class _MySongsListViewState extends State<MySongsListView> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;

  int _totalPagesFor(int totalItems) {
    if (totalItems <= 0) return 1;
    return (totalItems / MySongsListView.songsPerPage).ceil();
  }

  @override
  void didUpdateWidget(covariant MySongsListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final totalPages = _totalPagesFor(widget.songs.length);
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    } else if (oldWidget.songs.isEmpty && widget.songs.isNotEmpty) {
      _currentPage = 1;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToPage(int page, int totalPages) {
    final target = page.clamp(1, totalPages);
    if (target == _currentPage) return;
    setState(() => _currentPage = target);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: AppDurations.normal,
        curve: Curves.easeOut,
      );
    }
  }

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
    final playbackItems = widget.songs
        .map((s) => s.toSongModel().toPlaybackMap())
        .toList();
    final index = widget.songs.indexWhere((s) => s.id == song.id);
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

    if (widget.isLoading && widget.songs.isEmpty) {
      return AppSkeletonPulse(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, _) =>
              const AppSkeletonBox(height: 64, borderRadius: AppRadius.md),
        ),
      );
    }

    if (widget.songs.isEmpty) {
      return AppEmptyState(
        inCard: false,
        icon: Icons.library_music_rounded,
        title: context.l10n.noUploadedSongs,
        description: context.l10n.noUploadedSongsDesc,
      );
    }

    final totalPages = _totalPagesFor(widget.songs.length);
    final currentPage = _currentPage.clamp(1, totalPages);
    final startIndex = (currentPage - 1) * MySongsListView.songsPerPage;
    final endIndex = (startIndex + MySongsListView.songsPerPage).clamp(
      0,
      widget.songs.length,
    );
    final pagedSongs = widget.songs.sublist(startIndex, endIndex);

    return RefreshIndicator(
      color: colorScheme.primary,
      backgroundColor: appColors.cardSurface,
      onRefresh: () async {
        context.read<UploadBloc>().add(const LoadMySongsRequested());
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pagedSongs.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                thickness: 1,
                color: appColors.subtleBorder,
              ),
              itemBuilder: (context, index) {
                final song = pagedSongs[index];
                return _SongRowTile(
                  song: song,
                  textTheme: textTheme,
                  appColors: appColors,
                  colorScheme: colorScheme,
                  onTap: () => _onPlaySong(context, song),
                  onEdit: () => EditSongDialog.show(context, song),
                  onDelete: () => _confirmDelete(context, song),
                );
              },
            ),
            if (totalPages > 1) ...[
              const SizedBox(height: AppSpacing.md),
              _PaginationBar(
                currentPage: currentPage,
                totalPages: totalPages,
                startItem: startIndex + 1,
                endItem: endIndex,
                totalItems: widget.songs.length,
                onPageChanged: (page) => _goToPage(page, totalPages),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SongRowTile extends StatelessWidget {
  final SongEntity song;
  final TextTheme textTheme;
  final AppSemanticColors appColors;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SongRowTile({
    required this.song,
    required this.textTheme,
    required this.appColors,
    required this.colorScheme,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${song.title}, ${song.artist}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
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
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: appColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs + 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: appColors.inputFill,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                              border: Border.all(color: appColors.subtleBorder),
                            ),
                            child: Text(
                              song.isPublic
                                  ? context.l10n.public
                                  : context.l10n.private,
                              style: textTheme.labelSmall?.copyWith(
                                color: song.isPublic
                                    ? colorScheme.onSurface
                                    : appColors.textMuted,
                              ),
                            ),
                          ),
                          if (song.durationSec > 0)
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
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: context.l10n.editSong,
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: appColors.textMuted,
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
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
          ),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int startItem;
  final int endItem;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.startItem,
    required this.endItem,
    required this.totalItems,
    required this.onPageChanged,
  });

  List<int?> _visiblePages() {
    if (totalPages <= 5) {
      return List<int?>.generate(totalPages, (i) => i + 1);
    }

    final pages = <int>{
      1,
      totalPages,
      (currentPage - 1).clamp(1, totalPages),
      currentPage,
      (currentPage + 1).clamp(1, totalPages),
    }.toList()
      ..sort();

    final result = <int?>[];
    for (var i = 0; i < pages.length; i++) {
      if (i > 0) {
        final prev = pages[i - 1];
        final curr = pages[i];
        if (curr - prev == 2) {
          result.add(prev + 1);
        } else if (curr - prev > 2) {
          result.add(null);
        }
      }
      result.add(pages[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final visiblePages = _visiblePages();

    return AppCard(
      showBorder: true,
      borderRadius: AppRadius.lg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: context.l10n.previousPage,
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: visiblePages.map((page) {
                    if (page == null) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: Text(
                          '...',
                          style: textTheme.bodyMedium?.copyWith(
                            color: appColors.textMuted,
                          ),
                        ),
                      );
                    }

                    final isSelected = page == currentPage;
                    return Semantics(
                      button: true,
                      selected: isSelected,
                      label: '$page',
                      child: Material(
                        color: isSelected
                            ? colorScheme.primary
                            : appColors.inputFill,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          onTap: isSelected ? null : () => onPageChanged(page),
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary
                                    : appColors.subtleBorder,
                              ),
                            ),
                            child: Text(
                              '$page',
                              style: textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              IconButton(
                tooltip: context.l10n.nextPage,
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.showingSongsRange(startItem, endItem, totalItems),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: appColors.textMuted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
