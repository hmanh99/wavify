import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  static const empty = AuthTokens(accessToken: '', refreshToken: '');

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
