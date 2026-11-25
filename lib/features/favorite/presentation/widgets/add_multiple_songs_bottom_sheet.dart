import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/song_entity.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/usecases/get_available_songs_usecase.dart';
import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';

class AddMultipleSongsBottomSheet extends StatefulWidget {
  final PlaylistEntity playlist;
  final List<SongEntity>? availableSongs;
  static const int maxSelectable = 100;

  const AddMultipleSongsBottomSheet({
    super.key,
    required this.playlist,
    this.availableSongs,
  });

  static Future<void> show(
    BuildContext context,
    PlaylistEntity playlist, {
    List<SongEntity>? availableSongs,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PlaylistBloc>(),
        child: AddMultipleSongsBottomSheet(
          playlist: playlist,
          availableSongs: availableSongs,
        ),
      ),
    );
  }

  @override
  State<AddMultipleSongsBottomSheet> createState() =>
      _AddMultipleSongsBottomSheetState();
}

class _AddMultipleSongsBottomSheetState
    extends State<AddMultipleSongsBottomSheet> {
  final Set<String> _selectedSongIds = <String>{};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<SongEntity> _loadedSongs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.availableSongs != null) {
      _loadedSongs = widget.availableSongs!;
    } else {
      _fetchAvailableSongs();
    }
  }

  Future<void> _fetchAvailableSongs() async {
    setState(() => _isLoading = true);
    try {
      if (sl.isRegistered<GetAvailableSongsUseCase>()) {
        final songs = await sl<GetAvailableSongsUseCase>()();
        if (mounted) {
          setState(() {
            _loadedSongs = songs;
            _isLoading = false;
          });
        }
      } else if (sl.isRegistered<PlaylistRepository>()) {
        final songs = await sl<PlaylistRepository>().getAllSongs();
        if (mounted) {
          setState(() {
            _loadedSongs = songs;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelectSong(String songId) {
    setState(() {
      if (_selectedSongIds.contains(songId)) {
        _selectedSongIds.remove(songId);
      } else {
        if (_selectedSongIds.length >=
            AddMultipleSongsBottomSheet.maxSelectable) {
          final colorScheme = context.colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.selectedSongsCount(
                  _selectedSongIds.length,
                  AddMultipleSongsBottomSheet.maxSelectable,
                ),
                style: TextStyle(color: colorScheme.onError),
              ),
              backgroundColor: colorScheme.error,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _selectedSongIds.add(songId);
      }
    });
  }

  void _toggleSelectAll(List<SongEntity> availableSongs) {
    setState(() {
      if (_selectedSongIds.length == availableSongs.length &&
          availableSongs.isNotEmpty) {
        _selectedSongIds.clear();
      } else {
        _selectedSongIds.clear();
        for (final song in availableSongs.take(
          AddMultipleSongsBottomSheet.maxSelectable,
        )) {
          _selectedSongIds.add(song.id);
        }
      }
    });
  }

  void _onConfirmAdd(List<SongEntity> availableSongs) {
    if (_selectedSongIds.isEmpty) return;

    final songMap = {for (final s in availableSongs) s.id: s};
    final selectedEntities = _selectedSongIds
        .map((id) => songMap[id])
        .whereType<SongEntity>()
        .toList();

    context.read<PlaylistBloc>().add(
      AddSongsToPlaylistRequested(
        playlistId: widget.playlist.id,
        songIds: _selectedSongIds.toList(),
        songs: selectedEntities,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final librarySongs = _loadedSongs;
    final existingIds = widget.playlist.songs.map((s) => s.id).toSet();
    final unaddedSongs = librarySongs
        .where((s) => !existingIds.contains(s.id))
        .toList();

    final filteredSongs = _searchQuery.trim().isEmpty
        ? unaddedSongs
        : unaddedSongs.where((s) {
            final query = _searchQuery.toLowerCase();
            return s.title.toLowerCase().contains(query) ||
                s.artist.toLowerCase().contains(query);
          }).toList();

    final isAllSelected =
        filteredSongs.isNotEmpty &&
        _selectedSongIds.length >= filteredSongs.length &&
        filteredSongs.every((s) => _selectedSongIds.contains(s.id));

    return AppBottomSheetFrame(
      maxHeightFraction: 0.85,
      padding: EdgeInsets.fromLTRB(
        0,
        AppSpacing.md,
        0,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg + AppSpacing.xs,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.addSongsToPlaylist,
                                    style: textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    context.l10n.selectedSongsCount(
                                      _selectedSongIds.length,
                                      AddMultipleSongsBottomSheet.maxSelectable,
                                    ),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: _selectedSongIds.length >=
                                              AddMultipleSongsBottomSheet.maxSelectable
                                          ? colorScheme.error
                                          : appColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              if (unaddedSongs.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () => _toggleSelectAll(filteredSongs),
                                  icon: Icon(
                                    isAllSelected
                                        ? Icons.deselect_rounded
                                        : Icons.select_all_rounded,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                  label: Text(
                                    isAllSelected
                                        ? context.l10n.deselectAll
                                        : context.l10n.selectAll,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg + AppSpacing.xs,
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          textInputAction: TextInputAction.search,
                          style: textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: context.l10n.searchInLibrary,
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: appColors.textMuted,
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    tooltip: context.l10n.cancel,
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: appColors.textMuted,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Divider(height: 1, color: appColors.subtleBorder),
                    ],
                  ),
                ),
                if (_isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filteredSongs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      inCard: false,
                      icon: unaddedSongs.isEmpty
                          ? Icons.check_circle_outline_rounded
                          : Icons.music_off_outlined,
                      title: unaddedSongs.isEmpty
                          ? context.l10n.allSongsAlreadyAdded
                          : context.l10n.noMatchingSongsFound,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    sliver: SliverList.builder(
                      itemCount: filteredSongs.length,
                      itemBuilder: (context, index) {
                        final song = filteredSongs[index];
                        final isSelected = _selectedSongIds.contains(song.id);

                        return InkWell(
                          onTap: () => _toggleSelectSong(song.id),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleSelectSong(song.id),
                                ),
                                MusicArtwork(
                                  imageUrl: song.coverUrl,
                                  title: song.title,
                                  artist: song.artist,
                                  width: 44,
                                  height: 44,
                                  borderRadius: AppRadius.sm,
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
                                        style: textTheme.bodyLarge?.copyWith(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme.onSurface,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
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
                                if (song.durationSec > 0) ...[
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    AppFormatters.durationSeconds(
                                      song.durationSec,
                                    ),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: appColors.textMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg + AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.lg + AppSpacing.xs,
              AppSpacing.sm,
            ),
            child: AppPrimaryButton(
              icon: Icons.playlist_add_rounded,
              text: _selectedSongIds.isEmpty
                  ? context.l10n.addSongs
                  : context.l10n.addSelectedSongs(_selectedSongIds.length),
              onPressed: _selectedSongIds.isNotEmpty
                  ? () => _onConfirmAdd(unaddedSongs)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
