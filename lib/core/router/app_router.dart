import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/favorite/presentation/pages/all_favorites_page.dart';
import '../../features/favorite/presentation/pages/favourite_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/listen/presentation/pages/listen_page.dart';
import '../../features/favorite/presentation/pages/playlist_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/upload/presentation/pages/upload_music_page.dart';
import '../widgets/app_scaffold_with_nav_bar.dart';

class AppRouter {
  AppRouter._();

  static const String initial = signIn;
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String favourite = '/favourite';
  static const String favouriteAll = '/favourite/all';
  static const String listen = '/listen';
  static const String upload = '/upload';
  static const String profile = '/profile';
  static const String history = '/profile/history';
  static const String playlistDetail = '/playlist/:id';

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initial,
    debugLogDiagnostics: false,
    routes: [
      // Auth routes (outside the bottom navigation shell)
      GoRoute(
        path: signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: signUp,
        builder: (context, state) => const SignUpPage(),
      ),

      // Playlist detail route
      GoRoute(
        path: playlistDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PlaylistDetailPage(playlistId: id);
        },
      ),
      GoRoute(
        path: favouriteAll,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final initialTab = int.tryParse(tabParam ?? '0') ?? 0;
          return AllFavoritesPage(initialTabIndex: initialTab);
        },
      ),

      // Main App with Persistent Bottom Navigation Bar (5 tabs according to design)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // Branch 1: Favourite
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: favourite,
                builder: (context, state) => const FavouritePage(),
              ),
            ],
          ),

          // Branch 2: Listen (Song, playlist) - Center prominent button
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: listen,
                builder: (context, state) => ListenPage(argument: state.extra),
              ),
            ],
          ),

          // Branch 3: Upload music
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: upload,
                builder: (context, state) => const UploadMusicPage(),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'history',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const HistoryPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
