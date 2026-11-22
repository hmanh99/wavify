import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/bloc/locale_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/edit_profile_bottom_sheet.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_menu_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasBloc = false;
    try {
      context.read<ProfileBloc>();
      hasBloc = true;
    } catch (_) {
      hasBloc = false;
    }

    if (hasBloc) {
      return const _ProfileView();
    }

    return BlocProvider<ProfileBloc>(
      create: (_) => sl<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileInitial) {
      context.read<ProfileBloc>().add(const ProfileLoadRequested());
    }
  }

  void _showLogoutDialog(BuildContext context) {
    AppConfirmDialog.show(
      context,
      icon: Icons.logout_rounded,
      title: context.l10n.logoutConfirmTitle,
      message: context.l10n.logoutConfirmMessage,
      confirmLabel: context.l10n.logout,
      isDestructive: true,
      onConfirm: () {
        context.read<ProfileBloc>().add(const ProfileLogoutRequested());
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        Locale currentLocale = const Locale('vi');
        try {
          currentLocale = context.read<LocaleBloc>().state.locale;
        } catch (_) {}

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.language_rounded,
                color: colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Text(
                  context.l10n.selectLanguage,
                  style: textTheme.titleLarge,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  context.l10n.vietnamese,
                  style: textTheme.bodyLarge,
                ),
                trailing: currentLocale.languageCode == 'vi'
                    ? Icon(Icons.check_rounded, color: colorScheme.primary)
                    : null,
                onTap: () {
                  try {
                    context.read<LocaleBloc>().add(
                      const LocaleChangeRequested(Locale('vi')),
                    );
                  } catch (_) {}
                  Navigator.of(dialogCtx).pop();
                },
              ),
              ListTile(
                title: Text(context.l10n.english, style: textTheme.bodyLarge),
                trailing: currentLocale.languageCode == 'en'
                    ? Icon(Icons.check_rounded, color: colorScheme.primary)
                    : null,
                onTap: () {
                  try {
                    context.read<LocaleBloc>().add(
                      const LocaleChangeRequested(Locale('en')),
                    );
                  } catch (_) {}
                  Navigator.of(dialogCtx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoggedOut) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.loggedOutSuccess),
              duration: const Duration(seconds: 2),
            ),
          );
          context.go(AppRouter.signIn);
        } else if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: appColors.onSuccess),
              ),
              backgroundColor: appColors.success,
            ),
          );
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
        UserProfileEntity? profile;
        bool isBusy = false;

        if (state is ProfileLoaded) {
          profile = state.profile;
        } else if (state is ProfileUpdating) {
          profile = state.currentProfile;
          isBusy = true;
        } else if (state is ProfileUpdateSuccess) {
          profile = state.profile;
        } else if (state is ProfileFailure && state.profile != null) {
          profile = state.profile;
        } else if (state is ProfileLoading) {
          isBusy = true;
        }

        Locale currentLocale = const Locale('vi');
        try {
          currentLocale = context.watch<LocaleBloc>().state.locale;
        } catch (_) {}
        final languageSubtitle = currentLocale.languageCode == 'en'
            ? context.l10n.english
            : context.l10n.vietnamese;

        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          appBar: AppTopBar(
            showBackButton: false,
            title: context.l10n.myProfile,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
                tooltip: context.l10n.refresh,
                onPressed: () {
                  context.read<ProfileBloc>().add(const ProfileLoadRequested());
                },
              ),
            ],
          ),
          body: SafeArea(
            child: isBusy && profile == null
                ? const Center(child: CircularProgressIndicator())
                : profile == null
                ? AppErrorState(
                    inCard: false,
                    title: context.l10n.errorOccurred,
                    message: state is ProfileFailure
                        ? state.message
                        : context.l10n.loadSongsFailed,
                    onRetry: () {
                      context.read<ProfileBloc>().add(
                        const ProfileLoadRequested(),
                      );
                    },
                  )
                : RefreshIndicator(
                    color: colorScheme.primary,
                    backgroundColor: appColors.cardSurface,
                    onRefresh: () async {
                      context.read<ProfileBloc>().add(
                        const ProfileLoadRequested(),
                      );
                    },
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg + AppSpacing.xs,
                            vertical: AppSpacing.md,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 620),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ProfileHeaderCard(profile: profile),
                                  const SizedBox(height: AppSpacing.xl),
                                  ProfileMenuItem(
                                    icon: Icons.person_outline_rounded,
                                    title: context.l10n.editProfile,
                                    subtitle: context.l10n.editProfileSubtitle,
                                    onTap: () {
                                      EditProfileBottomSheet.show(
                                        context,
                                        profile!,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  ProfileMenuItem(
                                    icon: Icons.history_rounded,
                                    title: context.l10n.playbackHistory,
                                    subtitle:
                                        context.l10n.playbackHistorySubtitle,
                                    onTap: () {
                                      context.push('/profile/history');
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  ProfileMenuItem(
                                    icon: Icons.language_rounded,
                                    title: context.l10n.language,
                                    subtitle: languageSubtitle,
                                    onTap: () => _showLanguageDialog(context),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  ProfileMenuItem(
                                    icon: Icons.logout_rounded,
                                    title: context.l10n.logout,
                                    subtitle: context.l10n.logoutSubtitle,
                                    isDestructive: true,
                                    onTap: () => _showLogoutDialog(context),
                                  ),
                                  const SizedBox(height: AppSpacing.xxl),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isBusy)
                          Container(
                            color: appColors.overlay,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
