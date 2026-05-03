import 'package:equatable/equatable.dart';
import '../../../domain/entities/pet.dart';

abstract class PetEvent extends Equatable {
  const PetEvent();

  @override
  List<Object?> get props => [];
}

class LoadPets extends PetEvent {
  final String uid;

  const LoadPets(this.uid);

  @override
  List<Object?> get props => [uid];
}

class AddPet extends PetEvent {
  final String uid;
  final Pet pet;

  const AddPet({required this.uid, required this.pet});

  @override
  List<Object?> get props => [uid, pet];
}

class UpdatePet extends PetEvent {
  final String uid;
  final Pet pet;

  const UpdatePet({required this.uid, required this.pet});

  @override
  List<Object?> get props => [uid, pet];
}

class DeletePet extends PetEvent {
  final String uid;
  final String petId;

  const DeletePet({required this.uid, required this.petId});

  @override
  List<Object?> get props => [uid, petId];
}