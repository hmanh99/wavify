import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../data/models/song_model.dart';
import '../../domain/entities/playback_argument.dart';
import '../bloc/player_bloc.dart';
import '../bloc/player_event.dart';
import '../bloc/player_state.dart';
import '../widgets/player_artwork.dart';
import '../widgets/player_controls.dart';
import '../widgets/player_progress_bar.dart';
import '../widgets/playlist_queue_sheet.dart';

class ListenPage extends StatelessWidget {
  final Object? argument;

  const ListenPage({super.key, this.argument});

  @override
  Widget build(BuildContext context) {
    bool hasBloc = false;
    try {
      context.read<PlayerBloc>();
      hasBloc = true;
    } catch (_) {
      hasBloc = false;
    }

    if (!hasBloc && sl.isRegistered<PlayerBloc>()) {
      return BlocProvider<PlayerBloc>.value(
        value: sl<PlayerBloc>(),
        child: _ListenPageView(argument: argument),
      );
    }

    return _ListenPageView(argument: argument);
  }
}

class _ListenPageView extends StatefulWidget {
  final Object? argument;

  const _ListenPageView({this.argument});

  @override
  State<_ListenPageView> createState() => _ListenPageViewState();
}

class _ListenPageViewState extends State<_ListenPageView> {
  @override
  void initState() {
    super.initState();
    _handleArgument(widget.argument);
  }

  @override
  void didUpdateWidget(covariant _ListenPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.argument != oldWidget.argument && widget.argument != null) {
      _handleArgument(widget.argument);
    }
  }

  void _handleArgument(Object? arg) {
    if (arg is PlaybackArgument && arg.playlist.isNotEmpty) {
      context.read<PlayerBloc>().add(
        PlayerPlayPlaylistRequested(
          playlist: arg.playlist,
          initialIndex: arg.initialIndex,
        ),
      );
    } else if (arg is Map<String, dynamic>) {
      final playlist =
          arg['playlist'] as List<Map<String, dynamic>>? ?? const [];
      final initialIndex = arg['initialIndex'] as int? ?? 0;
      if (playlist.isNotEmpty) {
        context.read<PlayerBloc>().add(
          PlayerPlayPlaylistRequested(
            playlist: playlist,
            initialIndex: initialIndex,
          ),
        );
      }
    }
  }

  void _openQueue(BuildContext context, PlayerState state) {
    PlaylistQueueSheet.show(
      context,
      playlist: state.playlist,
      currentIndex: state.currentIndex,
      onSelectSong: (index) {
        context.read<PlayerBloc>().add(PlayerSelectIndexRequested(index));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final SongModel? song = state.currentSong;

        if (song == null) {
          return Scaffold(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: AppEmptyState(
                inCard: false,
                icon: Icons.music_note_rounded,
                title: context.l10n.noSongSelected,
                description: context.l10n.noSongSelectedDesc,
                actionLabel: context.l10n.exploreSongs,
                onAction: () => context.go(AppRouter.home),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg + AppSpacing.xs,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      PlayerArtwork(song: song),
                      const SizedBox(height: AppSpacing.xl),
                      PlayerProgressBar(
                        position: state.currentPosition,
                        duration: state.totalDuration,
                        onSeek: (position) {
                          context.read<PlayerBloc>().add(
                            PlayerSeekRequested(position),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PlayerControls(
                        isPlaying: state.isPlaying,
                        isShuffle: state.isShuffle,
                        isRepeat: state.isRepeat,
                        onPlayPause: () {
                          if (state.playlist.isEmpty) {
                            context.read<PlayerBloc>().add(
                              PlayerPlaySongRequested(song),
                            );
                          } else {
                            context.read<PlayerBloc>().add(
                              const PlayerPlayPauseToggled(),
                            );
                          }
                        },
                        onPrevious: () {
                          context.read<PlayerBloc>().add(
                            const PlayerPreviousRequested(),
                          );
                        },
                        onNext: () {
                          context.read<PlayerBloc>().add(
                            const PlayerNextRequested(),
                          );
                        },
                        onShuffleToggle: () {
                          context.read<PlayerBloc>().add(
                            const PlayerShuffleToggled(),
                          );
                        },
                        onRepeatToggle: () {
                          context.read<PlayerBloc>().add(
                            const PlayerRepeatToggled(),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton.icon(
                        onPressed: () => _openQueue(context, state),
                        icon: Icon(
                          Icons.queue_music_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        label: Text(
                          context.l10n.queueWithCount(state.playlist.length),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
