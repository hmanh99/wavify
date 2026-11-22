import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfileBottomSheet extends StatefulWidget {
  final UserProfileEntity profile;

  const EditProfileBottomSheet({super.key, required this.profile});

  static Future<void> show(BuildContext context, UserProfileEntity profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: EditProfileBottomSheet(profile: profile),
      ),
    );
  }

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _emailController = TextEditingController(text: widget.profile.email);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSave() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    context.read<ProfileBloc>().add(
      ProfileUpdateRequested(
        userId: widget.profile.id,
        username: username,
        email: email,
        password: password.isNotEmpty ? password : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: appColors.onSuccess),
              ),
              backgroundColor: appColors.success,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: colorScheme.onError),
              ),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isUpdating = state is ProfileUpdating;

        return AppBottomSheetFrame(
          maxHeightFraction: 0.9,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.editProfile,
                            style: textTheme.headlineSmall,
                          ),
                        ),
                        IconButton(
                          tooltip: context.l10n.cancel,
                          icon: Icon(
                            Icons.close_rounded,
                            color: appColors.textMuted,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: '${context.l10n.username} *',
                      hint: context.l10n.username,
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) {
                          return context.l10n.usernameEmailRequired;
                        }
                        if (v.length < 4) {
                          return context.l10n.usernameMinLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md + 2),
                    AppTextField(
                      label: '${context.l10n.email} *',
                      hint: context.l10n.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.usernameEmailRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md + 2),
                    AppTextField(
                      label: context.l10n.newPasswordHint,
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => isUpdating ? null : _onSave(),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 8) {
                          return context.l10n.passwordMinLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppPrimaryButton(
                      text: isUpdating
                          ? context.l10n.loading
                          : context.l10n.saveChanges,
                      isLoading: isUpdating,
                      onPressed: isUpdating ? null : _onSave,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
