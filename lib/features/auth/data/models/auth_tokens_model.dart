import '../../domain/entities/auth_tokens.dart';
import 'user_model.dart';

class AuthTokensModel extends AuthTokens {
  final UserModel? user;

  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    this.user,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('result') && json['result'] is Map<String, dynamic>) {
      data = json['result'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    } else if (json.containsKey('tokens') && json['tokens'] is Map<String, dynamic>) {
      data = json['tokens'] as Map<String, dynamic>;
    }

    final accessToken = (data['accessToken'] ??
            data['access_token'] ??
            data['token'] ??
            json['accessToken'] ??
            json['access_token'] ??
            '')
        .toString();

    final refreshToken = (data['refreshToken'] ??
            data['refresh_token'] ??
            json['refreshToken'] ??
            json['refresh_token'] ??
            '')
        .toString();

    UserModel? user;
    if (json['user'] is Map<String, dynamic>) {
      user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    } else if (data['user'] is Map<String, dynamic>) {
      user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } else if (data.containsKey('username') || data.containsKey('email')) {
      // If the response is a UserResponse (e.g. from /register)
      user = UserModel.fromJson(data);
    }

    return AuthTokensModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      if (user != null) 'user': user!.toJson(),
    };
  }
}
