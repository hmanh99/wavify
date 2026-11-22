import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wavify/core/l10n/app_l10n.dart';
import 'package:wavify/core/widgets/app_scaffold_with_nav_bar.dart';

void main() {
  group('AppScaffoldWithNavBar 5 Tabs Design Tests', () {
    testWidgets(
      'Renders all 5 navigation items: Home, Favourite, Listen, Upload, Profile',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final testRouter = GoRouter(
          initialLocation: '/home',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) {
                return AppScaffoldWithNavBar(navigationShell: navigationShell);
              },
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/home',
                      builder: (context, state) =>
                          const Text('Home Screen Content'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/favourite',
                      builder: (context, state) =>
                          const Text('Favourite Screen Content'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/listen',
                      builder: (context, state) =>
                          const Text('Listen Screen Content'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/upload',
                      builder: (context, state) =>
                          const Text('Upload Screen Content'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/profile',
                      builder: (context, state) =>
                          const Text('Profile Screen Content'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: testRouter,
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(AppScaffoldWithNavBar), findsOneWidget);
        expect(find.text('Home Screen Content'), findsOneWidget);

        // Verify all 5 tab tooltips exist
        expect(find.byTooltip('Home'), findsOneWidget);
        expect(find.byTooltip('Favourite'), findsOneWidget);
        expect(find.byTooltip('Listen'), findsOneWidget);
        expect(find.byTooltip('Upload'), findsOneWidget);
        expect(find.byTooltip('Profile'), findsOneWidget);

        // Verify the Center Floating Listen Button with music note icon
        expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);

        // Verify Upload music tray icon exists
        expect(find.byIcon(Icons.file_upload_outlined), findsOneWidget);

        // 1. Tap on Favourite tab (index 1)
        await tester.tap(find.byTooltip('Favourite'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Favourite Screen Content'), findsOneWidget);

        // 2. Tap on Listen center button (index 2)
        await tester.tap(find.byTooltip('Listen'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Listen Screen Content'), findsOneWidget);

        // 3. Tap on Upload music tab (index 3)
        await tester.tap(find.byTooltip('Upload'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Upload Screen Content'), findsOneWidget);

        // 4. Tap on Profile tab (index 4)
        await tester.tap(find.byTooltip('Profile'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Profile Screen Content'), findsOneWidget);

        // 5. Tap on Home tab (index 0)
        await tester.tap(find.byTooltip('Home'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Home Screen Content'), findsOneWidget);
      },
    );
  });
}
