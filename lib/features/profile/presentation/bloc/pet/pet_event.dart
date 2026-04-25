import 'package:equatable/equatable.dart';
import '../../../domain/entities/pet.dart';

abstract class PetEvent extends Equatable {
  const PetEvent();

  @override
  List<Object?> get props => [];
}

class LoadPets extends PetEvent {}

class AddPet extends PetEvent {
  final Pet pet;

  const AddPet(this.pet);

  @override
  List<Object?> get props => [pet];
}

class UpdatePet extends PetEvent {
  final Pet pet;

  const UpdatePet(this.pet);

  @override
  List<Object?> get props => [pet];
}

class DeletePet extends PetEvent {
  final String petId;

  const DeletePet(this.petId);

  @override
  List<Object?> get props => [petId];
}