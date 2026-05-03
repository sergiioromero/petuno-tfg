import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String uid;

  const LoadProfile(this.uid);

  @override
  List<Object?> get props => [uid];
}

class UpdateProfile extends ProfileEvent {
  final User user;

  const UpdateProfile(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateProfilePhoto extends ProfileEvent {
  final String uid;
  final String photoPath; // ruta local del archivo antes de subirlo

  const UpdateProfilePhoto({required this.uid, required this.photoPath});

  @override
  List<Object?> get props => [uid, photoPath];
}