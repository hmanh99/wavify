import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isShuffle;
  final bool isRepeat;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onShuffleToggle;
  final VoidCallback onRepeatToggle;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isShuffle,
    required this.isRepeat,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onShuffleToggle,
    required this.onRepeatToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appColors = context.appColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: 'Shuffle',
          style: IconButton.styleFrom(
            backgroundColor: isShuffle ? appColors.inputFill : null,
            side: isShuffle
                ? BorderSide(color: appColors.subtleBorder, width: 1)
                : null,
          ),
          icon: Icon(
            Icons.shuffle_rounded,
            size: 20,
            color: isShuffle ? colorScheme.primary : appColors.textMuted,
          ),
          onPressed: onShuffleToggle,
        ),
        IconButton(
          tooltip: 'Previous',
          icon: Icon(
            Icons.skip_previous_rounded,
            size: 30,
            color: colorScheme.onSurface,
          ),
          onPressed: onPrevious,
        ),
        Semantics(
          button: true,
          label: isPlaying ? 'Pause' : 'Play',
          child: Material(
            color: colorScheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPlayPause,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Center(
                  child: Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 28,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next',
          icon: Icon(
            Icons.skip_next_rounded,
            size: 30,
            color: colorScheme.onSurface,
          ),
          onPressed: onNext,
        ),
        IconButton(
          tooltip: 'Repeat',
          style: IconButton.styleFrom(
            backgroundColor: isRepeat ? appColors.inputFill : null,
            side: isRepeat
                ? BorderSide(color: appColors.subtleBorder, width: 1)
                : null,
          ),
          icon: Icon(
            Icons.repeat_rounded,
            size: 20,
            color: isRepeat ? colorScheme.primary : appColors.textMuted,
          ),
          onPressed: onRepeatToggle,
        ),
      ],
    );
  }
}
