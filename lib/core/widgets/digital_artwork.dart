import 'package:flutter/material.dart';
import '../constants/colors_constant.dart';
import '../theme/app_tokens.dart';

class DigitalArtwork extends StatelessWidget {
  final String? title;
  final String? artist;
  final double width;
  final double height;
  final double borderRadius;
  final double? iconSize;
  final bool showBadge;

  const DigitalArtwork({
    super.key,
    this.title,
    this.artist,
    this.width = 120,
    this.height = 120,
    this.borderRadius = AppRadius.md,
    this.iconSize,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize =
        iconSize ??
        (width > 0 && width.isFinite ? (width * 0.28).clamp(18.0, 40.0) : 24.0);
    final showRing = width.isFinite && width >= 72;

    final noteIcon = Icon(
      Icons.music_note_rounded,
      color: ColorsConstant.white,
      size: effectiveIconSize,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ColorsConstant.black,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: context.appColors.subtleBorder, width: 1.0),
        ),
        child: Center(
          child: showRing
              ? Container(
                  padding: EdgeInsets.all(width * 0.12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorsConstant.white.withValues(alpha: 0.14),
                      width: 1.0,
                    ),
                  ),
                  child: noteIcon,
                )
              : noteIcon,
        ),
      ),
    );
  }
}
