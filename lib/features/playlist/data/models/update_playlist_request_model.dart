class UpdatePlaylistRequestModel {
  final String? name;
  final String? description;
  final String? coverUrl;
  final String? visibility;

  const UpdatePlaylistRequestModel({
    this.name,
    this.description,
    this.coverUrl,
    this.visibility,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (coverUrl != null) map['coverUrl'] = coverUrl;
    if (visibility != null) map['visibility'] = visibility!.toUpperCase();
    return map;
  }
}

