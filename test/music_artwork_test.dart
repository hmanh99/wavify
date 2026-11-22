import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/widgets/digital_artwork.dart';
import 'package:wavify/core/widgets/music_artwork.dart';
import 'package:wavify/features/home/presentation/widgets/all_songs_section.dart';
import 'package:wavify/features/listen/presentation/widgets/player_artwork.dart';
import 'package:wavify/features/listen/data/models/song_model.dart';
import 'package:wavify/features/upload/data/models/song_response_model.dart';
import 'package:wavify/features/home/domain/entities/song_entity.dart';

void main() {
  group('Digital Artwork & MusicArtwork Tests for Songs without Cover', () {
    testWidgets('Renders DigitalArtwork when imageUrl is null (no fallback image requested)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MusicArtwork(
              imageUrl: null,
              title: 'Cosmic Echoes',
              artist: 'Starlight',
              width: 120,
              height: 120,
            ),
          ),
        ),
      );

      expect(find.byType(DigitalArtwork), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
    });

    testWidgets('Renders DigitalArtwork when imageUrl is empty string or whitespace', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MusicArtwork(
              imageUrl: '   ',
              title: 'Empty Song',
              artist: 'Artist',
              width: 80,
              height: 80,
            ),
          ),
        ),
      );

      expect(find.byType(DigitalArtwork), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
    });

    testWidgets('DigitalArtwork displays black background and white music note', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitalArtwork(
              title: 'Neon Odyssey',
              artist: 'Cyber Wave',
              width: 200,
              height: 200,
            ),
          ),
        ),
      );

      expect(find.byType(DigitalArtwork), findsOneWidget);
      final iconFinder = find.byIcon(Icons.music_note_rounded);
      expect(iconFinder, findsOneWidget);
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, Colors.white);
    });

    testWidgets('PlayerArtwork renders DigitalArtwork when song.coverUrl is null', (WidgetTester tester) async {
      const songWithoutCover = SongModel(
        id: 'song-null-cover',
        title: 'Celestial Waves',
        artist: 'Aura Sound',
        coverUrl: null,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerArtwork(song: songWithoutCover),
          ),
        ),
      );

      expect(find.text('Celestial Waves'), findsOneWidget);
      expect(find.text('Aura Sound'), findsOneWidget);
      expect(find.byType(DigitalArtwork), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('AllSongsSection displays DigitalArtwork for songs with no cover image', (WidgetTester tester) async {
      const songNoCover = SongEntity(
        id: 'no-cover-1',
        title: 'Song Without Artwork',
        artist: 'Indie Band',
        durationSec: 195,
        fileUrl: 'https://cloudinary.com/audio/song.mp3',
        coverUrl: null, // Null cover
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllSongsSection(
              songs: const [songNoCover],
              onSongTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Song Without Artwork'), findsOneWidget);
      expect(find.byType(DigitalArtwork), findsWidgets);
      expect(find.byType(Image), findsNothing);
    });

    test('SongResponseModel.fromJson parses missing/empty coverUrl to null', () {
      final jsonWithNullCover = {
        'id': 's1',
        'title': 'Track 1',
        'artist': 'Artist 1',
        'fileUrl': 'https://audio.mp3',
        'coverUrl': null,
      };

      final jsonWithEmptyCover = {
        'id': 's2',
        'title': 'Track 2',
        'artist': 'Artist 2',
        'fileUrl': 'https://audio.mp3',
        'coverUrl': '',
      };

      final model1 = SongResponseModel.fromJson(jsonWithNullCover);
      final model2 = SongResponseModel.fromJson(jsonWithEmptyCover);

      expect(model1.coverUrl, isNull);
      expect(model2.coverUrl, isNull);
    });
  });
}

