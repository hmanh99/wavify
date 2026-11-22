class SongUpdateRequestModel {
  final String title;
  final String artist;
  final String? album;
  final String visibility;

  const SongUpdateRequestModel({
    required this.title,
    required this.artist,
    this.album,
    this.visibility = 'PUBLIC',
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title.trim(),
      'artist': artist.trim(),
      'visibility': visibility.toUpperCase(),
    };
    if (album != null && album!.trim().isNotEmpty) {
      map['album'] = album!.trim();
    }
    return map;
  }
}

