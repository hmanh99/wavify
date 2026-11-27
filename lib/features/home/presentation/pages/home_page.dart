import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/playback_bridge.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../favorite/presentation/bloc/favorite_bloc.dart';
import '../../../favorite/presentation/bloc/favorite_event.dart';
import '../../../favorite/domain/entities/song_entity.dart' as playlist_song;
import '../../../favorite/presentation/bloc/playlist_bloc.dart';
import '../../../favorite/presentation/widgets/add_to_playlist_bottom_sheet.dart';
import '../../../history/domain/entities/history_entity.dart';
import '../../../history/presentation/bloc/history_bloc.dart';
import '../../../history/presentation/bloc/history_event.dart';
import '../../../history/presentation/bloc/history_state.dart';
import '../../data/models/song_model.dart';
import '../../domain/entities/song_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/recommend_songs_section.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/recently_played_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasBloc = false;
    try {
      context.read<HomeBloc>();
      hasBloc = true;
    } catch (_) {
      hasBloc = false;
    }

    if (hasBloc) {
      return const _HomeView();
    }

    if (!sl.isRegistered<HomeBloc>()) {
      initHomeDependencies();
    }

    return BlocProvider<HomeBloc>(
      create: (_) => sl<HomeBloc>()..add(const HomeLoadSongsRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final historyBloc = _readHistoryBloc(context);
      if (historyBloc != null && historyBloc.state is HistoryInitial) {
        historyBloc.add(const HistoryLoadRequested());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onPlaySongEntity(
    BuildContext context,
    SongEntity song,
    List<SongEntity> playlist, {
    Set<String> favoriteSongIds = const {},
  }) {
    final playbackItems = playlist.map((s) {
      final map = s.toSongModel().toPlaybackMap();
      if (favoriteSongIds.contains(s.id)) {
        map['isFavourite'] = true;
      }
      return map;
    }).toList();
    final index = playlist.indexWhere((s) => s.id == song.id);
    final targetIndex = index >= 0 ? index : 0;

    if (sl.isRegistered<PlaybackBridge>()) {
      sl<PlaybackBridge>().playPlaylist(
        playbackItems,
        initialIndex: targetIndex,
      );
    }

    context.go(AppRouter.listen);
  }

  void _onPlaySongModel(
    BuildContext context,
    SongModel song,
    List<SongModel> playlist, {
    Set<String> favoriteSongIds = const {},
  }) {
    final playbackItems = playlist.map((s) {
      final map = s.toPlaybackMap();
      if (favoriteSongIds.contains(s.id)) {
        map['isFavourite'] = true;
      }
      return map;
    }).toList();
    final index = playlist.indexOf(song);
    final targetIndex = index >= 0 ? index : 0;

    if (sl.isRegistered<PlaybackBridge>()) {
      sl<PlaybackBridge>().playPlaylist(
        playbackItems,
        initialIndex: targetIndex,
      );
    }

    context.go(AppRouter.listen);
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

  HistoryBloc? _readHistoryBloc(BuildContext context) {
    try {
      return context.read<HistoryBloc>();
    } catch (_) {
      return sl.isRegistered<HistoryBloc>() ? sl<HistoryBloc>() : null;
    }
  }

  SongModel _historyToHomeSongModel(HistoryEntity item) {
    final s = item.song;
    final rawCover = s.coverUrl?.trim();
    final cleanCover = (rawCover != null &&
            rawCover.isNotEmpty &&
            rawCover != 'null' &&
            rawCover != 'undefined')
        ? rawCover
        : null;
    return SongModel(
      id: s.id,
      title: s.title,
      artist: s.artist,
      album: s.album,
      coverUrl: cleanCover,
      duration: s.duration,
      fileUrl: s.fileUrl,
    );
  }

  List<SongModel> _buildRecentSongsFromHistory(List<HistoryEntity> history) {
    final seenIds = <String>{};
    final recentSongs = <SongModel>[];
    for (final item in history) {
      final id = item.song.id;
      if (id.isNotEmpty && !seenIds.add(id)) {
        continue;
      }
      recentSongs.add(_historyToHomeSongModel(item));
      if (recentSongs.length >= 10) {
        break;
      }
    }
    return recentSongs;
  }

  playlist_song.SongEntity _toPlaylistSong(SongEntity song) {
    return playlist_song.SongEntity(
      id: song.id,
      title: song.title,
      artist: song.artist,
      fileUrl: song.fileUrl,
      coverUrl: song.coverUrl,
      album: song.album,
      durationSec: song.durationSec,
    );
  }

  void _openAddToPlaylist(BuildContext context, SongEntity song) {
    try {
      context.read<PlaylistBloc>();
    } catch (_) {
      return;
    }
    AddToPlaylistBottomSheet.show(
      context,
      playlist_song.SongEntity(
        id: song.id,
        title: song.title,
        artist: song.artist,
        fileUrl: song.fileUrl,
        coverUrl: song.coverUrl,
        album: song.album,
        durationSec: song.durationSec,
      ),
    );
  }

  bool _hasPlaylistBloc(BuildContext context) {
    try {
      context.read<PlaylistBloc>();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeLoaded && state.allSongs.isNotEmpty) {
              final ids = state.allSongs
                  .map((s) => s.id)
                  .where((id) => id.isNotEmpty)
                  .toList();
              if (ids.isNotEmpty) {
                _readFavoriteBloc(
                  context,
                )?.add(CheckFavoriteSongsRequested(ids));
              }
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              color: colorScheme.primary,
              backgroundColor: appColors.cardSurface,
              onRefresh: () async {
                final homeCompleter = Completer<void>();
                context.read<HomeBloc>().add(
                  HomeRefreshRequested(completer: homeCompleter),
                );

                final historyBloc = _readHistoryBloc(context);
                Completer<void>? historyCompleter;
                if (historyBloc != null) {
                  historyCompleter = Completer<void>();
                  historyBloc.add(
                    HistoryLoadRequested(
                      isRefresh: true,
                      completer: historyCompleter,
                    ),
                  );
                }

                await Future.wait([
                  homeCompleter.future,
                  if (historyCompleter != null) historyCompleter.future,
                ]);
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg + AppSpacing.xs,
                  vertical: AppSpacing.md,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeSearchBar(
                          controller: _searchController,
                          onSearchChanged: (query) {
                            context.read<HomeBloc>().add(
                              HomeSearchQueryChanged(query),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _buildContent(context, state),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return _buildLoadingShimmer();
    }

    if (state is HomeFailure &&
        (state.cachedSongs == null || state.cachedSongs!.isEmpty)) {
      return AppErrorState(
        title: context.l10n.loadSongsFailed,
        message: state.message,
        onRetry: () {
          context.read<HomeBloc>().add(const HomeLoadSongsRequested());
        },
      );
    }

    List<SongEntity> allSongs = [];
    List<SongEntity> filteredSongs = [];
    List<SongEntity> recommendedSongs = [];
    bool isSearching = false;

    if (state is HomeLoaded) {
      allSongs = state.allSongs;
      filteredSongs = state.filteredSongs;
      recommendedSongs = state.recommendedSongs;
      isSearching = state.isSearching;
    } else if (state is HomeFailure && state.cachedSongs != null) {
      allSongs = state.cachedSongs!;
      filteredSongs = state.cachedSongs!;
      recommendedSongs = state.cachedSongs!;
    }

    final favBloc = _watchFavoriteBloc(context);
    final favoriteSongIds =
        favBloc?.state.favoriteSongIds ?? const <String>{};

    final onAdd = _hasPlaylistBloc(context)
        ? (SongEntity song) => _openAddToPlaylist(context, song)
        : null;
    final onToggleFav = favBloc != null
        ? (SongEntity song) => favBloc.add(
            ToggleFavoriteSongRequested(
              songId: song.id,
              song: _toPlaylistSong(song),
            ),
          )
        : null;

    if (isSearching) {
      return RecommendSongsSection(
        songs: filteredSongs,
        isSearching: true,
        favoriteSongIds: favoriteSongIds,
        onToggleFavorite: onToggleFav,
        onSongTap: (song) => _onPlaySongEntity(
          context,
          song,
          filteredSongs,
          favoriteSongIds: favoriteSongIds,
        ),
        onAddToPlaylist: onAdd,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecentSection(
          context,
          allSongs: allSongs,
          favoriteSongIds: favoriteSongIds,
        ),
        RecommendSongsSection(
          songs: recommendedSongs,
          isSearching: false,
          favoriteSongIds: favoriteSongIds,
          onToggleFavorite: onToggleFav,
          onShuffle: () => context.read<HomeBloc>().add(
            const HomeShuffleRecommendationsRequested(),
          ),
          onSongTap: (song) => _onPlaySongEntity(
            context,
            song,
            recommendedSongs,
            favoriteSongIds: favoriteSongIds,
          ),
          onAddToPlaylist: onAdd,
        ),
      ],
    );
  }

  Widget _buildRecentSection(
    BuildContext context, {
    required List<SongEntity> allSongs,
    required Set<String> favoriteSongIds,
  }) {
    final historyBloc = _readHistoryBloc(context);
    if (historyBloc == null) {
      final fallbackRecent = allSongs.take(5).map((s) => s.toSongModel()).toList();
      if (fallbackRecent.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecentlyPlayedSection(
            songs: fallbackRecent,
            onSongTap: (song) => _onPlaySongModel(
              context,
              song,
              fallbackRecent,
              favoriteSongIds: favoriteSongIds,
            ),
          ),
          const SizedBox(height: AppSpacing.xl + AppSpacing.xs),
        ],
      );
    }

    return BlocBuilder<HistoryBloc, HistoryState>(
      bloc: historyBloc,
      builder: (context, historyState) {
        if (historyState is! HistoryLoaded || historyState.history.isEmpty) {
          return const SizedBox.shrink();
        }
        final recentSongs = _buildRecentSongsFromHistory(historyState.history);
        if (recentSongs.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecentlyPlayedSection(
              songs: recentSongs,
              onSongTap: (song) => _onPlaySongModel(
                context,
                song,
                recentSongs,
                favoriteSongIds: favoriteSongIds,
              ),
            ),
            const SizedBox(height: AppSpacing.xl + AppSpacing.xs),
          ],
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return AppSkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeletonBox(
            width: 140,
            height: 18,
            borderRadius: AppRadius.sm,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, _) => const AppSkeletonBox(
                width: 120,
                height: 128,
                borderRadius: AppRadius.lg,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppSkeletonBox(
            width: 120,
            height: 18,
            borderRadius: AppRadius.sm,
          ),
          const SizedBox(height: AppSpacing.lg),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, _) =>
                const AppSkeletonBox(height: 72, borderRadius: AppRadius.lg),
          ),
        ],
      ),
    );
  }
}
