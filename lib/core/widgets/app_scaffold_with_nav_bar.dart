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
    const barHeight = 60.0;
    final totalHeight = barHeight + bottomPadding;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: navigationShell,
      bottomNavigationBar: Container(
        height: totalHeight,
        decoration: BoxDecoration(
          color: appColors.navBackground,
          border: Border(
            top: BorderSide(color: appColors.subtleBorder, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
                _CenterListenButton(
                  isSelected: currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
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

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: Tooltip(
          message: label,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onTap,
            child: Center(
              child: AnimatedScale(
                scale: isSelected ? 1.04 : 1.0,
                duration: AppDurations.normal,
                curve: Curves.easeOutCubic,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : appColors.subtleBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 25,
                      color: colorScheme.onPrimary,
                    ),
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
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onTap,
            child: SizedBox(
              height: 40,
              child: Icon(
                icon,
                size: 30,
                color: isSelected
                    ? colorScheme.onSurface
                    : appColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
