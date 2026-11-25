import '../../domain/entities/artist_entity.dart';

class ArtistModel extends ArtistEntity {
  const ArtistModel({
    required super.id,
    required super.name,
    super.avatarUrl,
    required super.followers,
  });
}

