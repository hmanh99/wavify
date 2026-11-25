import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/di/service_locator.dart';
import 'core/l10n/app_l10n.dart';
import 'core/l10n/bloc/locale_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/favorite/presentation/bloc/favorite_bloc.dart';
import 'features/favorite/presentation/bloc/favorite_event.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/bloc/home_event.dart';
import 'features/listen/presentation/bloc/player_bloc.dart';
import 'features/listen/presentation/bloc/player_event.dart';
import 'features/favorite/presentation/bloc/playlist_bloc.dart';
import 'features/favorite/presentation/bloc/playlist_event.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/upload/presentation/bloc/upload_bloc.dart';
import 'features/upload/presentation/bloc/upload_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleBloc>(
          create: (_) => LocaleBloc(
            secureStorage: sl.isRegistered<FlutterSecureStorage>()
                ? sl<FlutterSecureStorage>()
                : null,
          )..add(const LocaleLoadRequested()),
        ),
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(
            secureStorage: sl.isRegistered<FlutterSecureStorage>()
                ? sl<FlutterSecureStorage>()
                : null,
          )..add(const ThemeLoadRequested()),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>()..add(const ProfileLoadRequested()),
        ),
        BlocProvider<UploadBloc>(
          create: (_) => sl<UploadBloc>()..add(const LoadMySongsRequested()),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => sl<HomeBloc>()..add(const HomeLoadSongsRequested()),
        ),
        BlocProvider<PlaylistBloc>(
          create: (_) =>
              sl<PlaylistBloc>()..add(const LoadPlaylistsRequested()),
        ),
        BlocProvider<FavoriteBloc>(
          create: (_) => sl<FavoriteBloc>(),
        ),
        BlocProvider<HistoryBloc>(create: (_) => sl<HistoryBloc>()),
        BlocProvider<PlayerBloc>(
          create: (_) =>
              sl<PlayerBloc>()..add(const PlayerInitQueueRequested()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated) {
            context.read<FavoriteBloc>().add(const LoadFavoritesRequested());
            context.read<PlaylistBloc>().add(const LoadPlaylistsRequested());
            context.read<ProfileBloc>().add(const ProfileLoadRequested());
            context.read<UploadBloc>().add(const LoadMySongsRequested());
          } else if (authState is AuthUnauthenticated) {
            context.read<FavoriteBloc>().add(const ClearFavoritesRequested());
          }
        },
        child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, localeState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp.router(
                title: 'Wavify',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                routerConfig: AppRouter.router,
                locale: localeState.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
              );
            },
          );
        },
      ),
      ),
    );
  }
}
