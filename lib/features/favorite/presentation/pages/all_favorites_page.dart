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
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../data/models/song_model.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/song_entity.dart';
import '../bloc/playlist_bloc.dart';
import '../widgets/add_to_playlist_bottom_sheet.dart';
import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_event.dart';
import '../bloc/favorite_state.dart';

class AllFavoritesPage extends StatefulWidget {
  final int initialTabIndex;

  const AllFavoritesPage({super.key, this.initialTabIndex = 0});

  @override
  State<AllFavoritesPage> createState() => _AllFavoritesPageState();
}

class _AllFavoritesPageState extends State<AllFavoritesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  FavoriteBloc? _watchFavoriteBloc(BuildContext context) {
    try {
      return context.watch<FavoriteBloc>();
    } catch (_) {
      return sl.isRegistered<FavoriteBloc>() ? sl<FavoriteBloc>() : null;
    }
  }

  FavoriteBloc? _readFavoriteBloc(BuildContext context) {
    try {
      return context.read<FavoriteBloc>();
    } catch (_) {
      return sl.isRegistered<FavoriteBloc>() ? sl<FavoriteBloc>() : null;
    }
  }

  bool _hasPlaylistBloc(BuildContext context) {
    try {
      context.read<PlaylistBloc>();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _onPlaySong(
    BuildContext context,
    SongModel song,
    List<SongModel> playlist,
  ) {
    final playbackItems = playlist.map((s) => s.toPlaybackMap()).toList();
    final index = playlist.indexOf(song);
    final targetIndex = index >= 0 ? index : 0;

    if (sl.isRegistered<PlaybackBridge>()) {
      sl<PlaybackBridge>().playPlaylist(
        playbackItems,
        initialIndex: targetIndex,
      );
    }

    if (GoRouter.maybeOf(context) != null) {
      context.go(AppRouter.listen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final favBloc = _watchFavoriteBloc(context);
    final favState = favBloc?.state ?? const FavoriteState();

    final favoriteSongEntities = favState.favoriteSongs
        .map((item) => item.song)
        .toList();
    final favoritePlaylists = favState.favoritePlaylists
        .map((item) => item.playlist)
        .toList();

    final query = _searchQuery.trim().toLowerCase();
    final filteredSongEntities = query.isEmpty
        ? favoriteSongEntities
        : favoriteSongEntities.where((s) {
            return s.title.toLowerCase().contains(query) ||
                s.artist.toLowerCase().contains(query) ||
                (s.album?.toLowerCase().contains(query) ?? false);
          }).toList();
    final filteredSongModels = filteredSongEntities
        .map((s) => s.toSongModel().copyWith(isFavourite: true))
        .toList();

    final filteredPlaylists = query.isEmpty
        ? favoritePlaylists
        : favoritePlaylists.where((p) {
            return p.name.toLowerCase().contains(query) ||
                (p.ownerName?.toLowerCase().contains(query) ?? false);
          }).toList();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppTopBar(
        title: context.l10n.allFavoritesTitle,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text:
                  '${context.l10n.favoriteSongs} (${favoriteSongEntities.length})',
            ),
            Tab(
              text:
                  '${context.l10n.favoritePlaylists} (${favoritePlaylists.length})',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    textInputAction: TextInputAction.search,
                    style: textTheme.bodyLarge,
                    cursorColor: colorScheme.primary,
                    decoration: InputDecoration(
                      hintText: context.l10n.searchFavoritesHint,
                      filled: true,
                      fillColor: appColors.cardSurface,
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
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: appColors.subtleBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: appColors.subtleBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _SongsTab(
                        songs: filteredSongModels,
                        allEntities: filteredSongEntities,
                        isSearching: query.isNotEmpty,
                        hasPlaylistBloc: _hasPlaylistBloc(context),
                        onRefresh: () async {
                          _readFavoriteBloc(
                            context,
                          )?.add(const RefreshFavoritesRequested());
                        },
                        onSongTap: (song) =>
                            _onPlaySong(context, song, filteredSongModels),
                        onToggleFavorite: favBloc != null
                            ? (song, entity) => favBloc.add(
                                ToggleFavoriteSongRequested(
                                  songId: song.id,
                                  song: entity,
                                ),
                              )
                            : null,
                      ),
                      _PlaylistsTab(
                        playlists: filteredPlaylists,
                        isSearching: query.isNotEmpty,
                        onRefresh: () async {
                          _readFavoriteBloc(
                            context,
                          )?.add(const RefreshFavoritesRequested());
                        },
                        onPlaylistTap: (playlist) {
                          if (GoRouter.maybeOf(context) != null) {
                            context.push('/playlist/${playlist.id}');
                          }
                        },
                        onToggleFavorite: favBloc != null
                            ? (playlist) => favBloc.add(
                                ToggleFavoritePlaylistRequested(
                                  playlistId: playlist.id,
                                  playlist: playlist,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SongsTab extends StatelessWidget {
  final List<SongModel> songs;
  final List<SongEntity> allEntities;
  final bool isSearching;
  final bool hasPlaylistBloc;
  final Future<void> Function() onRefresh;
  final ValueChanged<SongModel> onSongTap;
  final void Function(SongModel song, SongEntity? entity)? onToggleFavorite;

  const _SongsTab({
    required this.songs,
    required this.allEntities,
    required this.isSearching,
    required this.hasPlaylistBloc,
    required this.onRefresh,
    required this.onSongTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final showInlineDuration = MediaQuery.sizeOf(context).width >= 380;

    return RefreshIndicator(
      color: colorScheme.primary,
      backgroundColor: appColors.cardSurface,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: songs.isEmpty
            ? AppEmptyState(
                icon: isSearching
                    ? Icons.search_off_rounded
                    : Icons.favorite_border_rounded,
                title: isSearching
                    ? context.l10n.noMatchingSongsFound
                    : context.l10n.noFavoriteSongs,
                description: isSearching
                    ? context.l10n.noSongsFoundDesc
                    : context.l10n.noFavoriteSongsDesc,
              )
            : AppCard(
                showBorder: true,
                borderRadius: AppRadius.lg,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: songs.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    thickness: 1,
                    color: appColors.subtleBorder,
                  ),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final entity = index < allEntities.length
                        ? allEntities[index]
                        : null;
                    final durationSec = song.duration.inSeconds;
                    final subtitleParts = <String>[
                      song.artist,
                      if (song.album != null && song.album!.isNotEmpty)
                        song.album!,
                      if (!showInlineDuration && durationSec > 0)
                        AppFormatters.durationSeconds(durationSec),
                    ];

                    return Semantics(
                      button: true,
                      label: '${song.title}, ${song.artist}',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          onTap: () => onSongTap(song),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm + 2,
                            ),
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
                                        subtitleParts.join(' • '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: appColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (showInlineDuration && durationSec > 0) ...[
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    AppFormatters.durationSeconds(durationSec),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: appColors.textMuted,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                                if (onToggleFavorite != null)
                                  IconButton(
                                    icon: Icon(
                                      Icons.favorite_rounded,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                    tooltip: context.l10n.removeFromFavorites,
                                    onPressed: () =>
                                        onToggleFavorite!(song, entity),
                                  ),
                                if (hasPlaylistBloc && entity != null)
                                  IconButton(
                                    icon: Icon(
                                      Icons.more_horiz_rounded,
                                      color: appColors.textMuted,
                                      size: 20,
                                    ),
                                    tooltip: context.l10n.addToPlaylist,
                                    onPressed: () {
                                      AddToPlaylistBottomSheet.show(
                                        context,
                                        entity,
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
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  final List<PlaylistEntity> playlists;
  final bool isSearching;
  final Future<void> Function() onRefresh;
  final ValueChanged<PlaylistEntity> onPlaylistTap;
  final ValueChanged<PlaylistEntity>? onToggleFavorite;

  const _PlaylistsTab({
    required this.playlists,
    required this.isSearching,
    required this.onRefresh,
    required this.onPlaylistTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return RefreshIndicator(
      color: colorScheme.primary,
      backgroundColor: appColors.cardSurface,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: playlists.isEmpty
            ? AppEmptyState(
                icon: isSearching
                    ? Icons.search_off_rounded
                    : Icons.favorite_border_rounded,
                title: isSearching
                    ? context.l10n.noPublicPlaylistsFound
                    : context.l10n.noFavoritePlaylists,
                description: isSearching
                    ? null
                    : context.l10n.noFavoritePlaylistsDesc,
              )
            : AppCard(
                showBorder: true,
                borderRadius: AppRadius.lg,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: playlists.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    thickness: 1,
                    color: appColors.subtleBorder,
                  ),
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final ownerLabel = (playlist.ownerName != null &&
                            playlist.ownerName!.trim().isNotEmpty)
                        ? playlist.ownerName!.trim()
                        : (playlist.isPublic
                              ? context.l10n.public
                              : context.l10n.private);
                    final subtitle = playlist.songCount > 0
                        ? '$ownerLabel • ${context.l10n.tracksCount(playlist.songCount)}'
                        : ownerLabel;

                    return Semantics(
                      button: true,
                      label: playlist.name,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          onTap: () => onPlaylistTap(playlist),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm + 2,
                            ),
                            child: Row(
                              children: [
                                MusicArtwork(
                                  imageUrl: playlist.displayCoverUrl,
                                  title: playlist.name,
                                  artist: ownerLabel,
                                  width: 48,
                                  height: 48,
                                  borderRadius: AppRadius.sm,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        playlist.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.titleMedium,
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
                                if (onToggleFavorite != null)
                                  IconButton(
                                    icon: Icon(
                                      Icons.favorite_rounded,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                    tooltip: context.l10n.removeFromFavorites,
                                    onPressed: () =>
                                        onToggleFavorite!(playlist),
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
    );
  }
}
