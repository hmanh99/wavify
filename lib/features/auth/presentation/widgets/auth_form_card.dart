import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

class AuthFormCard extends StatelessWidget {
  final Widget child;

  const AuthFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg + AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.lg + AppSpacing.xs,
        AppSpacing.xl,
      ),
      child: child,
    );
  }
}
