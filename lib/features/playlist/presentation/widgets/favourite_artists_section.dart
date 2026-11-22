import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../data/models/artist_model.dart';

class FavouriteArtistsSection extends StatelessWidget {
  final List<ArtistModel> artists;
  final ValueChanged<ArtistModel>? onArtistTap;

  const FavouriteArtistsSection({
    super.key,
    required this.artists,
    this.onArtistTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.favoriteArtists, style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md + 2),
        if (artists.isEmpty)
          AppEmptyState(
            icon: Icons.person_outline_rounded,
            title: context.l10n.noArtistsYet,
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < artists.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.lg),
                  _ArtistTile(
                    artist: artists[i],
                    onTap: onArtistTap != null
                        ? () => onArtistTap!(artists[i])
                        : null,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ArtistTile extends StatelessWidget {
  final ArtistModel artist;
  final VoidCallback? onTap;

  const _ArtistTile({required this.artist, this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final textTheme = context.textTheme;

    return Semantics(
      button: onTap != null,
      label: '${artist.name}, ${artist.followers}',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: SizedBox(
          width: 88,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: appColors.subtleBorder, width: 1),
                ),
                child: ClipOval(
                  child:
                      (artist.avatarUrl != null && artist.avatarUrl!.isNotEmpty)
                      ? Image.network(
                          artist.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _ArtistPlaceholder(appColors: appColors),
                        )
                      : _ArtistPlaceholder(appColors: appColors),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                artist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                artist.followers,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: appColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtistPlaceholder extends StatelessWidget {
  final AppSemanticColors appColors;

  const _ArtistPlaceholder({required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appColors.cardSurface,
      child: Icon(
        Icons.person_outline_rounded,
        color: appColors.textMuted,
        size: 32,
      ),
    );
  }
}
