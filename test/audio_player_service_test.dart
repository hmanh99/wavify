import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/features/playlist/data/models/album_model.dart';
import 'package:wavify/features/playlist/data/models/artist_model.dart';
import 'package:wavify/features/playlist/data/models/song_model.dart';
import 'package:wavify/features/upload/domain/entities/song_entity.dart';

void main() {
  group('Real Music Models & Entities Unit Tests', () {
    test('SongModel instantiates with real song attributes and supports copyWith', () {
      const song = SongModel(
        id: 'real_1',
        title: 'Real Symphony',
        artist: 'Real Artist',
        album: 'Real Album',
        coverUrl: 'https://example.com/cover.jpg',
        duration: Duration(minutes: 3, seconds: 45),
        fileUrl: 'https://example.com/audio.mp3',
        isFavourite: true,
      );

      expect(song.id, 'real_1');
      expect(song.title, 'Real Symphony');
      expect(song.artist, 'Real Artist');
      expect(song.album, 'Real Album');
      expect(song.coverUrl, 'https://example.com/cover.jpg');
      expect(song.duration, const Duration(minutes: 3, seconds: 45));
      expect(song.fileUrl, 'https://example.com/audio.mp3');
      expect(song.isFavourite, isTrue);

      final updated = song.copyWith(isFavourite: false, title: 'Updated Symphony');
      expect(updated.isFavourite, isFalse);
      expect(updated.title, 'Updated Symphony');
      expect(updated.id, 'real_1');
      expect(updated.artist, 'Real Artist');
    });

    test('SongEntity toSongModel converts backend entity to player song model accurately', () {
      const entity = SongEntity(
        id: 's_100',
        title: 'Backend Song',
        artist: 'Backend Artist',
        album: 'Backend Album',
        durationSec: 210,
        fileUrl: 'http://localhost:8080/api/v1/files/audio.mp3',
        coverUrl: 'http://localhost:8080/api/v1/files/cover.png',
        status: 'READY',
      );

      final model = entity.toSongModel();
      expect(model.id, 's_100');
      expect(model.title, 'Backend Song');
      expect(model.artist, 'Backend Artist');
      expect(model.album, 'Backend Album');
      expect(model.duration, const Duration(seconds: 210));
      expect(model.fileUrl, 'http://localhost:8080/api/v1/files/audio.mp3');
      expect(model.coverUrl, 'http://localhost:8080/api/v1/files/cover.png');
    });

    test('AlbumModel and ArtistModel instantiate correctly with songs and followers', () {
      const album = AlbumModel(
        id: 'alb_1',
        title: 'Studio Collection',
        artist: 'Studio Artist',
        coverUrl: 'https://example.com/album.jpg',
        songs: [
          SongModel(
            id: 's_1',
            title: 'Track 1',
            artist: 'Studio Artist',
            coverUrl: 'https://example.com/t1.jpg',
          ),
        ],
      );

      expect(album.id, 'alb_1');
      expect(album.title, 'Studio Collection');
      expect(album.songs.length, 1);

      const artist = ArtistModel(
        id: 'art_1',
        name: 'The Weeknd',
        avatarUrl: 'https://example.com/artist.jpg',
        followers: '5 bài hát',
      );

      expect(artist.id, 'art_1');
      expect(artist.name, 'The Weeknd');
      expect(artist.followers, '5 bài hát');
    });
  });
}
