import 'package:flutter/foundation.dart';

typedef TrackListenCallback = Future<void> Function(String songId);

abstract class PlaybackBridge {
  void playPlaylist(List<Map<String, dynamic>> playlist, {int initialIndex = 0});
  Set<String> get favouriteSongIds;
  ValueListenable<Set<String>> get favouriteSongIdsListenable;
}
