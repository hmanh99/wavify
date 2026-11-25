import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
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
    final appColors = context.appColors;

    return Row(
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(
              color: appColors.textMuted,
            ),
          ),
        ),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: isFavourite ? appColors.inputFill : null,
            side: isFavourite
                ? BorderSide(color: appColors.subtleBorder, width: 1)
                : null,
          ),
          tooltip: isFavourite
              ? context.l10n.removeFromFavorites
              : context.l10n.addToFavorites,
          icon: Icon(
            isFavourite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: isFavourite ? colorScheme.primary : colorScheme.onSurface,
            size: 22,
          ),
          onPressed: onFavouriteTap,
        ),
      ],
    );
  }
}
