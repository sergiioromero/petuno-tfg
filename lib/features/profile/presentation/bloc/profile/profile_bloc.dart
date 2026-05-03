import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/cloudinary_service.dart';
import '../../../domain/usecases/get_user.dart';
import '../../../domain/usecases/update_user.dart';
import '../../../domain/usecases/update_photo_url.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUser getUser;
  final UpdateUser updateUser;
  final UpdatePhotoURL updatePhotoURL;

  ProfileBloc({
    required this.getUser,
    required this.updateUser,
    required this.updatePhotoURL,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdateProfilePhoto>(_onUpdateProfilePhoto);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getUser(GetUserParams(event.uid));

    result.fold(
      (failure) {
        if (failure.message.contains('no encontrado')) {
          emit(ProfileNotFound());
        } else {
          emit(ProfileError(failure.message));
        }
      },
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;

    emit(ProfileLoading());

    final result = await updateUser(UpdateUserParams(event.user));

    result.fold(
      (failure) {
        if (currentState is ProfileLoaded) {
          emit(currentState);
        }
        emit(ProfileError(failure.message));
      },
      (_) => emit(ProfileLoaded(event.user)),
    );
  }

  Future<void> _onUpdateProfilePhoto(
    UpdateProfilePhoto event,
    Emitter<ProfileState> emit,
  ) async {
    // FIX: solo procedemos si hay datos de usuario cargados.
    // Si el estado no es ProfileLoaded (p.ej. doble tap durante una subida),
    // ignoramos el evento para evitar perder la referencia al usuario.
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    // Emitimos un estado especial de carga de foto para que la UI
    // pueda mostrar un indicador sin reemplazar los datos del perfil
    emit(ProfilePhotoUploading());

    try {
      // Subir la imagen a Cloudinary en la carpeta de avatares
      final photoURL = await CloudinaryService().uploadImage(
        event.photoPath,
        folder: 'avatars',
      );

      // Guardar la URL en Firestore
      final result = await updatePhotoURL(
        UpdatePhotoURLParams(uid: event.uid, photoURL: photoURL),
      );

      result.fold(
        (failure) {
          // Si falla el guardado en Firestore, restauramos el estado previo
          emit(currentState);
          emit(ProfileError(failure.message));
        },
        (_) {
          // Actualizamos el estado con la nueva URL de foto
          final updatedUser = currentState.user.copyWith(photoURL: photoURL);
          emit(ProfileLoaded(updatedUser));
        },
      );
    } catch (e) {
      emit(currentState);
      emit(ProfileError('Error al subir la foto: $e'));
    }
  }
}