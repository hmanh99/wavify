import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/playback_bridge.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../playlist/domain/entities/song_entity.dart' as playlist_song;
import '../../../playlist/presentation/bloc/playlist_bloc.dart';
import '../../../playlist/presentation/widgets/add_to_playlist_bottom_sheet.dart';
import '../../data/models/song_model.dart';
import '../../domain/entities/song_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/all_songs_section.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onPlaySongEntity(
    BuildContext context,
    SongEntity song,
    List<SongEntity> playlist,
  ) {
    final playbackItems = playlist
        .map((s) => s.toSongModel().toPlaybackMap())
        .toList();
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

    context.go(AppRouter.listen);
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
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: colorScheme.primary,
              backgroundColor: appColors.cardSurface,
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeRefreshRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
    bool isSearching = false;

    if (state is HomeLoaded) {
      allSongs = state.allSongs;
      filteredSongs = state.filteredSongs;
      isSearching = state.isSearching;
    } else if (state is HomeFailure && state.cachedSongs != null) {
      allSongs = state.cachedSongs!;
      filteredSongs = state.cachedSongs!;
    }

    final onAdd = _hasPlaylistBloc(context)
        ? (SongEntity song) => _openAddToPlaylist(context, song)
        : null;

    if (isSearching) {
      return AllSongsSection(
        songs: filteredSongs,
        isSearching: true,
        onSongTap: (song) => _onPlaySongEntity(context, song, filteredSongs),
        onAddToPlaylist: onAdd,
      );
    }

    final recentSongs = allSongs.take(8).map((s) => s.toSongModel()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recentSongs.isNotEmpty) ...[
          RecentlyPlayedSection(
            songs: recentSongs,
            onSongTap: (song) => _onPlaySongModel(context, song, recentSongs),
          ),
          const SizedBox(height: AppSpacing.xl + AppSpacing.xs),
        ],
        AllSongsSection(
          songs: allSongs,
          isSearching: false,
          onSongTap: (song) => _onPlaySongEntity(context, song, allSongs),
          onAddToPlaylist: onAdd,
        ),
      ],
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
