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
    this.borderRadius = AppRadius.lg,
    this.iconSize,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize =
        iconSize ??
        (width > 0 && width.isFinite ? (width * 0.40).clamp(20.0, 84.0) : 32.0);

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
          child: Icon(
            Icons.music_note_rounded,
            color: ColorsConstant.white,
            size: effectiveIconSize,
          ),
        ),
      ),
    );
  }
}
