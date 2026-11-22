import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_l10n.dart';
import '../theme/app_tokens.dart';

class AppScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffoldWithNavBar({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final appColors = context.appColors;
    const barHeight = 64.0;
    const protrusion = 16.0;
    final totalHeight = barHeight + protrusion + bottomPadding;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: navigationShell,
      bottomNavigationBar: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: protrusion),
              height: barHeight + bottomPadding,
              decoration: BoxDecoration(
                color: appColors.navBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
                border: Border(
                  top: BorderSide(color: appColors.subtleBorder, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      _NavBarItem(
                        icon: currentIndex == 0
                            ? Icons.home_rounded
                            : Icons.home_outlined,
                        isSelected: currentIndex == 0,
                        onTap: () => _onTap(0),
                        tooltip: context.l10n.navHome,
                      ),
                      _NavBarItem(
                        icon: currentIndex == 1
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        isSelected: currentIndex == 1,
                        onTap: () => _onTap(1),
                        tooltip: context.l10n.navFavourite,
                      ),
                      const SizedBox(width: 68),
                      _NavBarItem(
                        icon: currentIndex == 3
                            ? Icons.file_upload_rounded
                            : Icons.file_upload_outlined,
                        isSelected: currentIndex == 3,
                        onTap: () => _onTap(3),
                        tooltip: context.l10n.navUpload,
                      ),
                      _NavBarItem(
                        icon: currentIndex == 4
                            ? Icons.person_rounded
                            : Icons.person_outline_rounded,
                        isSelected: currentIndex == 4,
                        onTap: () => _onTap(4),
                        tooltip: context.l10n.navProfile,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: _CenterListenButton(
                isSelected: currentIndex == 2,
                onTap: () => _onTap(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterListenButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterListenButton({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appColors = context.appColors;
    final label = context.l10n.navListen;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Tooltip(
        message: label,
        child: AnimatedScale(
          scale: isSelected ? 1.04 : 1.0,
          duration: AppDurations.normal,
          curve: Curves.easeOutCubic,
          child: Material(
            color: colorScheme.primary,
            shape: CircleBorder(
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : appColors.subtleBorder,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: 60,
                height: 60,
                child: Center(
                  child: Icon(
                    Icons.music_note_rounded,
                    size: 30,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appColors = context.appColors;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: tooltip,
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Center(
              child: AnimatedContainer(
                duration: AppDurations.normal,
                curve: Curves.easeOutCubic,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? colorScheme.primary : appColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
