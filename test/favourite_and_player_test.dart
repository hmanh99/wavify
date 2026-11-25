import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/features/favorite/presentation/pages/favourite_page.dart';
import 'package:wavify/features/favorite/presentation/widgets/favourite_albums_section.dart';
import 'package:wavify/features/favorite/presentation/widgets/favourite_artists_section.dart';
import 'package:wavify/features/favorite/presentation/widgets/favourite_music_grid.dart';
import 'package:wavify/features/listen/presentation/widgets/player_header.dart';

void main() {
  group('PlayerHeader Tests', () {
    testWidgets('PlayerHeader does NOT display back arrow and displays title and favorite icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: PlayerHeader(
              title: 'Take care of you by Admina',
              isFavourite: true,
              onFavouriteTap: () {},
            ),
          ),
        ),
      );

      // Verify NO back arrow
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.arrow_back_ios), findsNothing);
      expect(find.byIcon(Icons.chevron_left), findsNothing);

      // Verify title and favorite icon
      expect(find.text('Take care of you by Admina'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });
  });

  group('FavouritePage Tests', () {
    testWidgets('FavouritePage does NOT display back arrow or old artist profile, only artists, playlists and songs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const FavouritePage(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify NO back arrow
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // Verify NO Sarwar Jahan artist profile card
      expect(find.text('Sarwar Jahan'), findsNothing);
      expect(find.text('sarwarmusic@gmail.com'), findsNothing);
      expect(find.text('Love Music and I am not an Musician .'), findsNothing);

      // Verify ONLY Favorite Artists, Playlists, Songs
      expect(find.byType(FavouriteArtistsSection), findsOneWidget);
      expect(find.text('Favorite Artists'), findsOneWidget);

      expect(find.byType(FavouriteAlbumsSection), findsOneWidget);
      expect(find.text('Playlists'), findsOneWidget);

      expect(find.byType(FavouriteMusicGrid), findsOneWidget);
      expect(find.text('Songs'), findsOneWidget);
    });
  });
}

