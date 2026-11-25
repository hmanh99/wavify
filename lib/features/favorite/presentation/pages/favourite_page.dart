import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/playback_bridge.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_event.dart';
import '../bloc/favorite_state.dart';
import 'all_favorites_page.dart';
import '../widgets/discover_playlists_bottom_sheet.dart';
import '../widgets/favorite_playlists_section.dart';
import '../../data/models/artist_model.dart';
import '../../data/models/song_model.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/song_entity.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/usecases/search_public_playlists_usecase.dart';
import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';
import '../widgets/create_edit_playlist_dialog.dart';
import '../widgets/favourite_albums_section.dart';
import '../widgets/favourite_artists_section.dart';
import '../widgets/favourite_music_grid.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final favBloc = _readFavoriteBloc(context);
      if (favBloc != null && favBloc.state.status == FavoriteStatus.initial) {
        favBloc.add(const LoadFavoritesRequested());
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

  PlaylistBloc? _watchPlaylistBloc(BuildContext context) {
    try {
      return context.watch<PlaylistBloc>();
    } catch (_) {
      return sl.isRegistered<PlaylistBloc>() ? sl<PlaylistBloc>() : null;
    }
  }

  PlaylistBloc? _readPlaylistBloc(BuildContext context) {
    try {
      return context.read<PlaylistBloc>();
    } catch (_) {
      return sl.isRegistered<PlaylistBloc>() ? sl<PlaylistBloc>() : null;
    }
  }

  void _onPlaySong(
    BuildContext context,
    SongModel song,
    List<SongModel> list,
  ) {
    final playbackItems = list.map((s) => s.toPlaybackMap()).toList();
    final index = list.indexOf(song);
    final targetIndex = index >= 0 ? index : 0;

    if (sl.isRegistered<PlaybackBridge>()) {
      sl<PlaybackBridge>().playPlaylist(
        playbackItems,
        initialIndex: targetIndex,
      );
    }

    context.go('/listen');
  }

  void _onPlaylistTap(BuildContext context, String playlistId) {
    context.push('/playlist/$playlistId');
  }

  void _openAllFavorites(BuildContext context, {required int initialTabIndex}) {
    if (GoRouter.maybeOf(context) != null) {
      context.push('${AppRouter.favouriteAll}?tab=$initialTabIndex');
      return;
    }

    final favBloc = _readFavoriteBloc(context);
    final playlistBloc = _readPlaylistBloc(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          Widget page = AllFavoritesPage(initialTabIndex: initialTabIndex);
          if (favBloc != null && playlistBloc != null) {
            page = MultiBlocProvider(
              providers: [
                BlocProvider<FavoriteBloc>.value(value: favBloc),
                BlocProvider<PlaylistBloc>.value(value: playlistBloc),
              ],
              child: page,
            );
          } else if (favBloc != null) {
            page = BlocProvider<FavoriteBloc>.value(
              value: favBloc,
              child: page,
            );
          } else if (playlistBloc != null) {
            page = BlocProvider<PlaylistBloc>.value(
              value: playlistBloc,
              child: page,
            );
          }
          return page;
        },
      ),
    );
  }

  void _onArtistTap(
    BuildContext context,
    ArtistModel artist,
    List<SongEntity> favoriteSongs,
  ) {
    final artistSongs = favoriteSongs
        .where(
          (s) =>
              s.artist.trim().toLowerCase() == artist.name.trim().toLowerCase(),
        )
        .map((s) => s.toSongModel().copyWith(isFavourite: true))
        .toList();

    if (artistSongs.isNotEmpty) {
      _onPlaySong(context, artistSongs.first, artistSongs);
    }
  }

  bool get _canDiscoverPlaylists =>
      sl.isRegistered<SearchPublicPlaylistsUseCase>() ||
      sl.isRegistered<PlaylistRepository>();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;

    final favBloc = _watchFavoriteBloc(context);
    final favState = favBloc?.state ?? const FavoriteState();
    final playlistBloc = _watchPlaylistBloc(context);
    final myPlaylists = playlistBloc?.state.playlists ?? const <PlaylistEntity>[];

    final favoriteSongEntities = favState.favoriteSongs
        .map((item) => item.song)
        .toList();
    final favoriteSongModels = favoriteSongEntities
        .map((s) => s.toSongModel().copyWith(isFavourite: true))
        .toList();
    final favoritePlaylists = favState.favoritePlaylists
        .map((item) => item.playlist)
        .toList();
    final myAlbumModels = myPlaylists.map((p) => p.toAlbumModel()).toList();
    final myPlaylistsById = {for (final p in myPlaylists) p.id: p};

    // Derive Favorite Artists strictly from user's favorited songs
    final artistsMap = <String, List<SongEntity>>{};
    for (final song in favoriteSongEntities) {
      final artistName = song.artist.trim();
      if (artistName.isNotEmpty) {
        artistsMap.putIfAbsent(artistName, () => []).add(song);
      }
    }

    final artists = artistsMap.entries.map((entry) {
      final firstSong = entry.value.first;
      final count = entry.value.length;
      return ArtistModel(
        id: 'art_${entry.key.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}',
        name: entry.key,
        avatarUrl: firstSong.coverUrl,
        followers: context.l10n.tracksCount(count),
      );
    }).toList();

    final showSkeleton =
        favState.isLoading &&
        favoriteSongModels.isEmpty &&
        favoritePlaylists.isEmpty;

    final showErrorState =
        favState.status == FavoriteStatus.failure &&
        favoriteSongModels.isEmpty &&
        favoritePlaylists.isEmpty &&
        myAlbumModels.isEmpty;

    final bodyContent = showSkeleton
        ? _buildLoadingSkeleton()
        : showErrorState
        ? AppErrorState(
            inCard: false,
            title: context.l10n.errorOccurred,
            message: favState.errorMessage ?? context.l10n.errorOccurred,
            onRetry: () {
              _readFavoriteBloc(context)?.add(const LoadFavoritesRequested());
            },
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FavouriteArtistsSection(
                artists: artists,
                onArtistTap: (artist) =>
                    _onArtistTap(context, artist, favoriteSongEntities),
              ),
              Divider(height: AppSpacing.xxl, color: appColors.subtleBorder),
              FavoritePlaylistsSection(
                playlists: favoritePlaylists,
                onPlaylistTap: (playlist) =>
                    _onPlaylistTap(context, playlist.id),
                onToggleFavorite: favBloc != null
                    ? (playlist) => favBloc.add(
                        ToggleFavoritePlaylistRequested(
                          playlistId: playlist.id,
                          playlist: playlist,
                        ),
                      )
                    : null,
                onDiscoverTap: (favBloc != null && _canDiscoverPlaylists)
                    ? () => DiscoverPlaylistsBottomSheet.show(context)
                    : null,
                onSeeMoreTap: () =>
                    _openAllFavorites(context, initialTabIndex: 1),
              ),
              Divider(height: AppSpacing.xxl, color: appColors.subtleBorder),
              FavouriteAlbumsSection(
                albums: myAlbumModels,
                favoriteAlbumIds: favState.favoritePlaylistIds,
                onAlbumTap: (album) => _onPlaylistTap(context, album.id),
                onCreatePlaylistTap: playlistBloc != null
                    ? () => CreateEditPlaylistDialog.show(context)
                    : null,
                onToggleFavorite: favBloc != null
                    ? (album) {
                        final playlist = myPlaylistsById[album.id];
                        favBloc.add(
                          ToggleFavoritePlaylistRequested(
                            playlistId: album.id,
                            playlist: playlist,
                          ),
                        );
                      }
                    : null,
              ),
              Divider(height: AppSpacing.xxl, color: appColors.subtleBorder),
              FavouriteMusicGrid(
                songs: favoriteSongModels,
                onSongTap: (song) =>
                    _onPlaySong(context, song, favoriteSongModels),
                onToggleFavorite: favBloc != null
                    ? (song) {
                        final entity = favoriteSongEntities.cast<SongEntity?>().firstWhere(
                          (s) => s?.id == song.id,
                          orElse: () => null,
                        );
                        favBloc.add(
                          ToggleFavoriteSongRequested(
                            songId: song.id,
                            song: entity,
                          ),
                        );
                      }
                    : null,
                onSeeMoreTap: () =>
                    _openAllFavorites(context, initialTabIndex: 0),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );

    final scaffold = Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: RefreshIndicator(
              color: colorScheme.primary,
              backgroundColor: appColors.cardSurface,
              onRefresh: () async {
                _readFavoriteBloc(
                  context,
                )?.add(const RefreshFavoritesRequested());
                _readPlaylistBloc(
                  context,
                )?.add(const RefreshPlaylistsRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg + AppSpacing.xs,
                  vertical: AppSpacing.lg,
                ),
                child: bodyContent,
              ),
            ),
          ),
        ),
      ),
    );

    if (favBloc == null) {
      return scaffold;
    }

    return BlocListener<FavoriteBloc, FavoriteState>(
      bloc: favBloc,
      listenWhen: (prev, curr) =>
          curr.status == FavoriteStatus.failure &&
          curr.errorMessage != null &&
          curr.errorMessage != prev.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage!,
              style: TextStyle(color: colorScheme.onError),
            ),
            backgroundColor: colorScheme.error,
          ),
        );
      },
      child: scaffold,
    );
  }

  Widget _buildLoadingSkeleton() {
    return AppSkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          AppSkeletonBox(width: 150, height: 18),
          SizedBox(height: AppSpacing.md),
          AppSkeletonBox(height: 110, borderRadius: AppRadius.lg),
          SizedBox(height: AppSpacing.xl),
          AppSkeletonBox(width: 140, height: 18),
          SizedBox(height: AppSpacing.md),
          AppSkeletonBox(height: 120, borderRadius: AppRadius.lg),
          SizedBox(height: AppSpacing.xl),
          AppSkeletonBox(width: 120, height: 18),
          SizedBox(height: AppSpacing.md),
          AppSkeletonBox(height: 120, borderRadius: AppRadius.lg),
          SizedBox(height: AppSpacing.xl),
          AppSkeletonBox(width: 100, height: 18),
          SizedBox(height: AppSpacing.md),
          AppSkeletonBox(height: 180, borderRadius: AppRadius.lg),
        ],
      ),
    );
  }
}
