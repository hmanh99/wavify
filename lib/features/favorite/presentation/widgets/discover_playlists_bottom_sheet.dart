import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/usecases/search_public_playlists_usecase.dart';
import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_event.dart';
import '../bloc/favorite_state.dart';

class DiscoverPlaylistsBottomSheet extends StatefulWidget {
  const DiscoverPlaylistsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    FavoriteBloc? favBloc;
    try {
      favBloc = context.read<FavoriteBloc>();
    } catch (_) {
      if (sl.isRegistered<FavoriteBloc>()) {
        favBloc = sl<FavoriteBloc>();
      }
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => favBloc != null
          ? BlocProvider<FavoriteBloc>.value(
              value: favBloc,
              child: const DiscoverPlaylistsBottomSheet(),
            )
          : const DiscoverPlaylistsBottomSheet(),
    );
  }

  @override
  State<DiscoverPlaylistsBottomSheet> createState() =>
      _DiscoverPlaylistsBottomSheetState();
}

class _DiscoverPlaylistsBottomSheetState
    extends State<DiscoverPlaylistsBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<PlaylistEntity> _playlists = const [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(keyword: value);
    });
  }

  Future<void> _search({String? keyword}) async {
    final hasUseCase = sl.isRegistered<SearchPublicPlaylistsUseCase>();
    final hasRepo = sl.isRegistered<PlaylistRepository>();
    if (!hasUseCase && !hasRepo) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final results = hasUseCase
          ? await sl<SearchPublicPlaylistsUseCase>()(keyword: keyword)
          : await sl<PlaylistRepository>().searchPublicPlaylists(
              keyword: keyword,
            );

      if (!mounted) return;
      setState(() {
        _playlists = results;
        _isLoading = false;
      });

      final ids = results.map((p) => p.id).where((id) => id.isNotEmpty).toList();
      if (ids.isNotEmpty) {
        try {
          context.read<FavoriteBloc>().add(CheckFavoritePlaylistsRequested(ids));
        } catch (_) {}
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;

    return AppBottomSheetFrame(
      maxHeightFraction: 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.discoverPublicPlaylists,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (val) => _search(keyword: val),
            style: textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: context.l10n.searchPlaylistsHint,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: appColors.textMuted,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: context.l10n.cancel,
                      icon: Icon(
                        Icons.close_rounded,
                        color: appColors.textMuted,
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _search();
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: appColors.subtleBorder),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? AppErrorState(
                    inCard: false,
                    title: context.l10n.errorOccurred,
                    message: _error!,
                    onRetry: () => _search(keyword: _searchController.text),
                  )
                : _playlists.isEmpty
                ? AppEmptyState(
                    inCard: false,
                    icon: Icons.queue_music_rounded,
                    title: context.l10n.noPublicPlaylistsFound,
                  )
                : BlocBuilder<FavoriteBloc, FavoriteState>(
                    builder: (context, favState) {
                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _playlists.length,
                        separatorBuilder: (_, _) => Divider(
                          height: AppSpacing.sm,
                          color: appColors.subtleBorder,
                        ),
                        itemBuilder: (context, index) {
                          final playlist = _playlists[index];
                          final isFav = favState.isPlaylistFavorite(
                            playlist.id,
                          );
                          final subtitle = (playlist.ownerName != null &&
                                  playlist.ownerName!.isNotEmpty)
                              ? playlist.ownerName!
                              : context.l10n.public;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: MusicArtwork(
                              imageUrl: playlist.displayCoverUrl,
                              title: playlist.name,
                              artist: subtitle,
                              width: 48,
                              height: 48,
                              borderRadius: AppRadius.md,
                            ),
                            title: Text(
                              playlist.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: appColors.textMuted,
                              ),
                            ),
                            trailing: IconButton(
                              tooltip: isFav
                                  ? context.l10n.removeFromFavorites
                                  : context.l10n.addToFavorites,
                              icon: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFav
                                    ? colorScheme.primary
                                    : appColors.textMuted,
                              ),
                              onPressed: () {
                                context.read<FavoriteBloc>().add(
                                  ToggleFavoritePlaylistRequested(
                                    playlistId: playlist.id,
                                    playlist: playlist,
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              context.push('/playlist/${playlist.id}');
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
