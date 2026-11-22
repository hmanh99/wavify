import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

class PlayerHeader extends StatelessWidget {
  final String title;
  final bool isFavourite;
  final VoidCallback? onBack;
  final VoidCallback onFavouriteTap;

  const PlayerHeader({
    super.key,
    required this.title,
    required this.isFavourite,
    this.onBack,
    required this.onFavouriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Row(
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: isFavourite ? 'Remove from favourites' : 'Add to favourites',
          icon: Icon(
            isFavourite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: isFavourite ? colorScheme.primary : colorScheme.onSurface,
            size: 24,
          ),
          onPressed: onFavouriteTap,
        ),
      ],
    );
  }
}
