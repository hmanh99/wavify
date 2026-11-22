import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/services/playback_bridge.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../data/models/album_model.dart';
import '../../data/models/artist_model.dart';
import '../../data/models/song_model.dart';
import '../../domain/entities/song_entity.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/usecases/get_available_songs_usecase.dart';
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
  List<SongEntity> _availableSongs = [];
  bool _isLoadingSongs = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableSongs();
  }

  Future<void> _loadAvailableSongs() async {
    final hasSource =
        sl.isRegistered<GetAvailableSongsUseCase>() ||
        sl.isRegistered<PlaylistRepository>();
    if (!hasSource) return;

    if (mounted) setState(() => _isLoadingSongs = true);
    try {
      if (sl.isRegistered<GetAvailableSongsUseCase>()) {
        final songs = await sl<GetAvailableSongsUseCase>()();
        if (mounted) {
          setState(() {
            _availableSongs = songs;
            _isLoadingSongs = false;
          });
        }
      } else if (sl.isRegistered<PlaylistRepository>()) {
        final songs = await sl<PlaylistRepository>().getAllSongs();
        if (mounted) {
          setState(() {
            _availableSongs = songs;
            _isLoadingSongs = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSongs = false);
    }
  }

  void _onPlaySong(BuildContext context, SongModel song, List<SongModel> list) {
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

  void _onPlayAlbum(BuildContext context, AlbumModel album) {
    if (album.songs.isNotEmpty) {
      final playbackItems = album.songs.map((s) => s.toPlaybackMap()).toList();
      if (sl.isRegistered<PlaybackBridge>()) {
        sl<PlaybackBridge>().playPlaylist(playbackItems, initialIndex: 0);
      }

      context.go('/listen');
    }
  }

  void _onAlbumOrPlaylistTap(BuildContext context, AlbumModel album) {
    if (!album.id.startsWith('alb_')) {
      context.push('/playlist/${album.id}');
    } else {
      _onPlayAlbum(context, album);
    }
  }

  void _onArtistTap(
    BuildContext context,
    ArtistModel artist,
    List<SongEntity> realSongs,
  ) {
    final artistSongs = realSongs
        .where(
          (s) =>
              s.artist.trim().toLowerCase() == artist.name.trim().toLowerCase(),
        )
        .map((s) => s.toSongModel())
        .toList();

    if (artistSongs.isNotEmpty) {
      _onPlaySong(context, artistSongs.first, artistSongs);
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

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final List<SongEntity> realSongs = _availableSongs;

    Set<String> favIds = const {};
    if (sl.isRegistered<PlaybackBridge>()) {
      favIds = sl<PlaybackBridge>().favouriteSongIds;
    }

    final artistsMap = <String, List<SongEntity>>{};
    for (final song in realSongs) {
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

    final albumsMap = <String, List<SongEntity>>{};
    for (final song in realSongs) {
      final albumName = song.album?.trim();
      if (albumName != null && albumName.isNotEmpty) {
        albumsMap.putIfAbsent(albumName, () => []).add(song);
      }
    }

    final albums = albumsMap.entries.map((entry) {
      final firstSong = entry.value.first;
      return AlbumModel(
        id: 'alb_${entry.key.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}',
        title: entry.key,
        artist: firstSong.artist,
        coverUrl: firstSong.coverUrl,
        songs: entry.value.map((s) => s.toSongModel()).toList(),
      );
    }).toList();

    List<AlbumModel> displayedPlaylists = [];
    try {
      final playlistState = context.watch<PlaylistBloc>().state;
      if (playlistState.playlists.isNotEmpty) {
        displayedPlaylists = playlistState.playlists
            .map((p) => p.toAlbumModel())
            .toList();
      }
    } catch (_) {
      if (sl.isRegistered<PlaylistBloc>()) {
        final playlistState = sl<PlaylistBloc>().state;
        if (playlistState.playlists.isNotEmpty) {
          displayedPlaylists = playlistState.playlists
              .map((p) => p.toAlbumModel())
              .toList();
        }
      }
    }

    final effectiveAlbums = displayedPlaylists.isNotEmpty
        ? displayedPlaylists
        : albums;

    final explicitlyFavorited = realSongs
        .where((s) => favIds.contains(s.id))
        .map((s) => s.toSongModel().copyWith(isFavourite: true))
        .toList();

    final favouriteSongs = explicitlyFavorited.isNotEmpty
        ? explicitlyFavorited
        : realSongs.map((s) => s.toSongModel()).toList();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: RefreshIndicator(
              color: colorScheme.primary,
              backgroundColor: appColors.cardSurface,
              onRefresh: () async {
                await _loadAvailableSongs();
                if (!context.mounted) return;
                try {
                  context.read<PlaylistBloc>().add(
                    const RefreshPlaylistsRequested(),
                  );
                } catch (_) {
                  if (sl.isRegistered<PlaylistBloc>()) {
                    sl<PlaylistBloc>().add(const RefreshPlaylistsRequested());
                  }
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg + AppSpacing.xs,
                  vertical: AppSpacing.lg,
                ),
                child: _isLoadingSongs && realSongs.isEmpty
                    ? _buildLoadingSkeleton()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FavouriteArtistsSection(
                            artists: artists,
                            onArtistTap: (artist) =>
                                _onArtistTap(context, artist, realSongs),
                          ),
                          const SizedBox(height: AppSpacing.xl + AppSpacing.xs),
                          FavouriteAlbumsSection(
                            albums: effectiveAlbums,
                            onAlbumTap: (album) =>
                                _onAlbumOrPlaylistTap(context, album),
                            onCreatePlaylistTap: _hasPlaylistBloc(context)
                                ? () => CreateEditPlaylistDialog.show(context)
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.xl + AppSpacing.xs),
                          FavouriteMusicGrid(
                            songs: favouriteSongs,
                            onSongTap: (song) =>
                                _onPlaySong(context, song, favouriteSongs),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
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
