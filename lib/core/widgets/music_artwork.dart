import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'digital_artwork.dart';

class MusicArtwork extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? artist;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;
  final double? iconSize;
  final bool showBadge;

  const MusicArtwork({
    super.key,
    required this.imageUrl,
    this.title,
    this.artist,
    this.width = 120,
    this.height = 120,
    this.borderRadius = AppRadius.md,
    this.fit = BoxFit.cover,
    this.iconSize,
    this.showBadge = true,
  });

  bool get _hasValidUrl {
    if (imageUrl == null) return false;
    final trimmed = imageUrl!.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed == 'null' || trimmed == 'undefined') return false;
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  Widget _buildDigitalArtwork() {
    return DigitalArtwork(
      title: title,
      artist: artist,
      width: width,
      height: height,
      borderRadius: borderRadius,
      iconSize: iconSize,
      showBadge: showBadge,
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no valid coverUrl is provided, treat as null and render Digital Artwork directly (no fallback)
    if (!_hasValidUrl) {
      return _buildDigitalArtwork();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Image.network(
            imageUrl!.trim(),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildDigitalArtwork();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildDigitalArtwork();
            },
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: context.appColors.subtleBorder,
                    width: 0.75,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
