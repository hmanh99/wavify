import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Minimalist primary/secondary/destructive button with >= 48dp hit target
/// and UI-level double-tap protection.
class AppPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double minHeight;
  final IconData? icon;
  final bool isSecondary;
  final bool isDestructive;

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
    double height = 50,
    this.icon,
    this.isSecondary = false,
    this.isDestructive = false,
  }) : minHeight = height < 48 ? 48 : height;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _isDebouncing = false;
  bool _isPressed = false;

  void _handleTap() {
    if (_isDebouncing || widget.isLoading || widget.onPressed == null) return;
    _isDebouncing = true;
    widget.onPressed!();
    Future.delayed(AppDurations.slow, () {
      if (mounted) _isDebouncing = false;
    });
  }

  Widget _wrapPressMotion(Widget child, {required bool enabled}) {
    return Listener(
      onPointerDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onPointerUp: enabled ? (_) => setState(() => _isPressed = false) : null,
      onPointerCancel:
          enabled ? (_) => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: (_isPressed && enabled) ? 0.985 : 1.0,
        duration: AppDurations.fast,
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appColors = context.appColors;

    final Widget content = widget.isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isSecondary
                    ? colorScheme.onSurface
                    : widget.isDestructive
                    ? colorScheme.onError
                    : colorScheme.onPrimary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final VoidCallback? effectiveOnPressed =
        (widget.isLoading || widget.onPressed == null) ? null : _handleTap;

    if (widget.isSecondary) {
      return _wrapPressMotion(
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: widget.minHeight,
            minWidth: widget.width ?? 0,
          ),
          child: SizedBox(
            width: widget.width,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: appColors.subtleBorder),
                minimumSize: Size(48, widget.minHeight),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: effectiveOnPressed,
              child: content,
            ),
          ),
        ),
        enabled: effectiveOnPressed != null,
      );
    }

    final bgColor = widget.isDestructive
        ? colorScheme.error
        : colorScheme.primary;
    final fgColor = widget.isDestructive
        ? colorScheme.onError
        : colorScheme.onPrimary;

    return _wrapPressMotion(
      ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: widget.minHeight,
          minWidth: widget.width ?? 0,
        ),
        child: SizedBox(
          width: widget.width,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              elevation: AppElevation.none,
              minimumSize: Size(48, widget.minHeight),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: effectiveOnPressed,
            child: content,
          ),
        ),
      ),
      enabled: effectiveOnPressed != null,
    );
  }
}
