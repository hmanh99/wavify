import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';

class HomeSearchBar extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;
  final TextEditingController? controller;

  const HomeSearchBar({
    super.key,
    this.onSearchChanged,
    this.onSearchTap,
    this.controller,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _internalController;
  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        return TextField(
          controller: _controller,
          onTap: widget.onSearchTap,
          onChanged: widget.onSearchChanged,
          textInputAction: TextInputAction.search,
          style: textTheme.bodyLarge,
          cursorColor: colorScheme.primary,
          decoration: InputDecoration(
            hintText: context.l10n.searchPlaceholder,
            filled: true,
            fillColor: appColors.cardSurface,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: appColors.textMuted,
              size: 20,
            ),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    tooltip: context.l10n.cancel,
                    icon: Icon(
                      Icons.close_rounded,
                      color: appColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () {
                      _controller.clear();
                      widget.onSearchChanged?.call('');
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: appColors.subtleBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: appColors.subtleBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
            ),
          ),
        );
      },
    );
  }
}
