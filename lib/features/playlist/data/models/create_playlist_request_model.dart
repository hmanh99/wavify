class CreatePlaylistRequestModel {
  final String name;
  final String? description;
  final String? coverUrl;
  final String visibility;

  const CreatePlaylistRequestModel({
    required this.name,
    this.description,
    this.coverUrl,
    this.visibility = 'PUBLIC',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (coverUrl != null && coverUrl!.isNotEmpty) 'coverUrl': coverUrl,
      'visibility': visibility.toUpperCase(),
    };
  }
}

