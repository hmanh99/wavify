import 'package:flutter/material.dart';
import '../l10n/app_l10n.dart';
import '../theme/app_tokens.dart';

/// Consistent minimalist AppBar with unified back navigation, hairline divider, and clean actions.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBack;
  final bool showBackButton;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const AppTopBar({
    super.key,
    this.title,
    this.onBack,
    this.showBackButton = true,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 1.0));

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return AppBar(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      elevation: AppElevation.none,
      scrolledUnderElevation: AppElevation.none,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              tooltip: context.l10n.goBack,
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleLarge,
            )
          : null,
      actions: actions,
      bottom: bottom ??
          PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              height: 1.0,
              color: appColors.subtleBorder,
            ),
          ),
    );
  }
}
