import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/services/playback_bridge.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/music_artwork.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasBloc = false;
    try {
      context.read<HistoryBloc>();
      hasBloc = true;
    } catch (_) {
      hasBloc = false;
    }

    if (!hasBloc && sl.isRegistered<HistoryBloc>()) {
      return BlocProvider<HistoryBloc>(
        create: (_) => sl<HistoryBloc>(),
        child: const _HistoryView(),
      );
    }

    return const _HistoryView();
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HistoryBloc>().add(const HistoryLoadRequested());
      }
    });
  }

  String _formatPlayedAt(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) {
      return context.l10n.justNow;
    } else if (diff.inMinutes < 60) {
      return context.l10n.minutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return context.l10n.hoursAgo(diff.inHours);
    } else if (diff.inDays < 7) {
      return context.l10n.daysAgo(diff.inDays);
    } else {
      return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}';
    }
  }

  void _showClearConfirmDialog(BuildContext context) {
    AppConfirmDialog.show(
      context,
      icon: Icons.delete_outline_rounded,
      title: context.l10n.clearHistoryConfirmTitle,
      message: context.l10n.clearHistoryConfirmMessage,
      confirmLabel: context.l10n.delete,
      isDestructive: true,
      onConfirm: () {
        context.read<HistoryBloc>().add(const HistoryClearRequested());
      },
    );
  }

  void _playFromHistory(
    BuildContext context,
    List<dynamic> historyList,
    int index,
  ) {
    final allSongs = historyList
        .map((h) => h.song.toPlaybackMap() as Map<String, dynamic>)
        .toList();
    if (sl.isRegistered<PlaybackBridge>()) {
      sl<PlaybackBridge>().playPlaylist(allSongs, initialIndex: index);
    }
    try {
      context.push('/listen');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppTopBar(
        title: context.l10n.historyTitle,
        onBack: () => Navigator.of(context).canPop()
            ? Navigator.of(context).pop()
            : (context.canPop() ? context.pop() : null),
        actions: [
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              final hasItems =
                  state is HistoryLoaded && state.history.isNotEmpty;
              if (!hasItems) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: appColors.textMuted,
                ),
                tooltip: context.l10n.clearHistory,
                onPressed: () => _showClearConfirmDialog(context),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            tooltip: context.l10n.refresh,
            onPressed: () {
              context.read<HistoryBloc>().add(
                const HistoryLoadRequested(isRefresh: true),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return AppSkeletonPulse(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: 5,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, _) => const AppSkeletonBox(
                    height: 72,
                    borderRadius: AppRadius.lg,
                  ),
                ),
              );
            }

            if (state is HistoryFailure) {
              return AppErrorState(
                inCard: false,
                title: context.l10n.errorOccurred,
                message: state.message,
                onRetry: () {
                  context.read<HistoryBloc>().add(const HistoryLoadRequested());
                },
              );
            }

            if (state is HistoryLoaded) {
              if (state.history.isEmpty) {
                return AppEmptyState(
                  inCard: false,
                  icon: Icons.history_rounded,
                  title: context.l10n.emptyHistory,
                  description: context.l10n.emptyHistoryDesc,
                );
              }

              final historyList = state.history;

              return RefreshIndicator(
                color: colorScheme.primary,
                backgroundColor: appColors.cardSurface,
                onRefresh: () async {
                  context.read<HistoryBloc>().add(
                    const HistoryLoadRequested(isRefresh: true),
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
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
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: historyList.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            thickness: 1,
                            color: appColors.subtleBorder,
                          ),
                          itemBuilder: (context, index) {
                            final item = historyList[index];
                            final song = item.song;

                            return Dismissible(
                              key: Key('hist_${item.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.lg + AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: colorScheme.onError,
                                ),
                              ),
                              onDismissed: (_) {
                                context.read<HistoryBloc>().add(
                                  HistoryDeleteItemRequested(item.id),
                                );
                              },
                              child: Semantics(
                                button: true,
                                label: '${song.title}, ${song.artist}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                    onTap: () => _playFromHistory(
                                      context,
                                      historyList,
                                      index,
                                    ),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: textTheme.titleMedium,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${song.artist} • ${_formatPlayedAt(context, item.playedAt)}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            appColors.textMuted,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            tooltip: context.l10n.delete,
                                            icon: Icon(
                                              Icons.more_horiz_rounded,
                                              color: appColors.textMuted,
                                              size: 20,
                                            ),
                                            onSelected: (value) {
                                              if (value == 'delete') {
                                                context.read<HistoryBloc>().add(
                                                  HistoryDeleteItemRequested(
                                                    item.id,
                                                  ),
                                                );
                                              }
                                            },
                                            itemBuilder: (_) => [
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      color: colorScheme.error,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(
                                                      width: AppSpacing.sm,
                                                    ),
                                                    Text(
                                                      context.l10n.delete,
                                                      style: TextStyle(
                                                        color:
                                                            colorScheme.error,
                                                      ),
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
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
