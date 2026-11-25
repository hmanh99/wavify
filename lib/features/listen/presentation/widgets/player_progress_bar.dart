import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';

class PlayerProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const PlayerProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appColors = context.appColors;
    final textTheme = context.textTheme;
    final maxSec = duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0;
    final currentSec = position.inSeconds.toDouble().clamp(0.0, maxSec);

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: appColors.subtleBorder,
              thumbColor: colorScheme.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              overlayColor: colorScheme.primary.withValues(alpha: 0.14),
            ),
            child: Slider(
              value: currentSec,
              min: 0,
              max: maxSec,
              onChanged: (value) {
                onSeek(Duration(seconds: value.toInt()));
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppFormatters.duration(position),
                style: textTheme.bodySmall?.copyWith(
                  color: appColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                AppFormatters.duration(duration),
                style: textTheme.bodySmall?.copyWith(
                  color: appColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
