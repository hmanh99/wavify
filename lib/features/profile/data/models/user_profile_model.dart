import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.username,
    required super.email,
    super.role = 'USER',
    super.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('result') && json['result'] is Map<String, dynamic>) {
      data = json['result'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    } else if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
      data = json['user'] as Map<String, dynamic>;
    }

    DateTime? createdAt;
    final rawDate = data['created_at'] ?? data['createdAt'];
    if (rawDate != null) {
      if (rawDate is String) {
        createdAt = DateTime.tryParse(rawDate);
      } else if (rawDate is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(rawDate);
      }
    }

    return UserProfileModel(
      id: (data['id'] ?? data['_id'] ?? data['userId'] ?? '').toString(),
      username: (data['username'] ??
              data['fullName'] ??
              data['full_name'] ??
              data['name'] ??
              'User')
          .toString(),
      email: (data['email'] ?? '').toString(),
      role: (data['role'] ?? 'USER').toString(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

