import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // In case user object is nested inside "user", "data" or "result"
    final data = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : (json['result'] is Map<String, dynamic>
                ? json['result'] as Map<String, dynamic>
                : json));

    return UserModel(
      id: (data['id'] ?? data['_id'] ?? data['userId'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      fullName: (data['username'] ??
              data['fullName'] ??
              data['full_name'] ??
              data['name'] ??
              '')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
    };
  }
}
