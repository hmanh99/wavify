import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String role;
  final DateTime? createdAt;

  const UserProfileEntity({
    required this.id,
    required this.username,
    required this.email,
    this.role = 'USER',
    this.createdAt,
  });

  UserProfileEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    DateTime? createdAt,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, username, email, role, createdAt];
}

