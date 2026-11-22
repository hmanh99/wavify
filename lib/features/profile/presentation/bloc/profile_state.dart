import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final UserProfileEntity currentProfile;

  const ProfileUpdating(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}

class ProfileUpdateSuccess extends ProfileState {
  final UserProfileEntity profile;
  final String message;

  const ProfileUpdateSuccess(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

class ProfileFailure extends ProfileState {
  final String message;
  final UserProfileEntity? profile;

  const ProfileFailure(this.message, {this.profile});

  @override
  List<Object?> get props => [message, profile];
}

class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}

