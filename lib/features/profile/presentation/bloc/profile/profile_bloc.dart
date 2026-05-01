import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_user.dart';
import '../../../domain/usecases/update_user.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUser getUser;
  final UpdateUser updateUser;

  ProfileBloc({
    required this.getUser,
    required this.updateUser,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getUser(GetUserParams(event.uid));

    result.fold(
      (failure) {
        // Si el mensaje indica que no existe el documento → estado especial
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
}