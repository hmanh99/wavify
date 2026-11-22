import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String userId;
  final String? username;
  final String? email;
  final String? password;

  const ProfileUpdateRequested({
    required this.userId,
    this.username,
    this.email,
    this.password,
  });

  @override
  List<Object?> get props => [userId, username, email, password];
}

class ProfileLogoutRequested extends ProfileEvent {
  const ProfileLogoutRequested();
}

