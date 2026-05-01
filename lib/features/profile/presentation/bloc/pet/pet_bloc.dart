import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_pets.dart';
import '../../../domain/usecases/add_pet.dart' as add;
import '../../../domain/usecases/update_pet.dart' as update;
import '../../../domain/usecases/delete_pet.dart' as delete;
import 'pet_event.dart';
import 'pet_state.dart';

class PetBloc extends Bloc<PetEvent, PetState> {
  final GetPets getPets;
  final add.AddPet addPet;
  final update.UpdatePet updatePet;
  final delete.DeletePet deletePet;

  PetBloc({
    required this.getPets,
    required this.addPet,
    required this.updatePet,
    required this.deletePet,
  }) : super(PetInitial()) {
    on<LoadPets>(_onLoadPets);
    on<AddPet>(_onAddPet);
    on<UpdatePet>(_onUpdatePet);
    on<DeletePet>(_onDeletePet);
  }

  Future<void> _onLoadPets(
    LoadPets event,
    Emitter<PetState> emit,
  ) async {
    emit(PetLoading());
    
    final result = await getPets(NoParams());
    
    result.fold(
      (failure) => emit(PetError(failure.message)),
      (pets) => emit(PetLoaded(pets)),
    );
  }

  Future<void> _onAddPet(
    AddPet event,
    Emitter<PetState> emit,
  ) async {
    if (state is PetLoaded) {
      emit(PetLoading());
      
      final result = await addPet(add.AddPetParams(event.pet));
      
      await result.fold(
        (failure) async => emit(PetError(failure.message)),
        (_) async {
          final petsResult = await getPets(NoParams());
          petsResult.fold(
            (failure) => emit(PetError(failure.message)),
            (pets) => emit(PetLoaded(pets)),
          );
        },
      );
    }
  }

  Future<void> _onUpdatePet(
    UpdatePet event,
    Emitter<PetState> emit,
  ) async {
    if (state is PetLoaded) {
      emit(PetLoading());
      
      final result = await updatePet(update.UpdatePetParams(event.pet));
      
      await result.fold(
        (failure) async => emit(PetError(failure.message)),
        (_) async {
          final petsResult = await getPets(NoParams());
          petsResult.fold(
            (failure) => emit(PetError(failure.message)),
            (pets) => emit(PetLoaded(pets)),
          );
        },
      );
    }
  }

  Future<void> _onDeletePet(
    DeletePet event,
    Emitter<PetState> emit,
  ) async {
    if (state is PetLoaded) {
      emit(PetLoading());
      
      final result = await deletePet(delete.DeletePetParams(event.petId));
      
      await result.fold(
        (failure) async => emit(PetError(failure.message)),
        (_) async {
          final petsResult = await getPets(NoParams());
          petsResult.fold(
            (failure) => emit(PetError(failure.message)),
            (pets) => emit(PetLoaded(pets)),
          );
        },
      );
    }
  }
}