import 'package:equatable/equatable.dart';

class ArtistEntity extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String followers;

  const ArtistEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.followers,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, followers];
}

