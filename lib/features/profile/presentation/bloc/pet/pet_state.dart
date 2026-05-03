import 'package:equatable/equatable.dart';
import '../../../domain/entities/pet.dart';

abstract class PetState extends Equatable {
  const PetState();

  @override
  List<Object?> get props => [];
}

class PetInitial extends PetState {}

class PetLoading extends PetState {}

class PetLoaded extends PetState {
  final List<Pet> pets;

  const PetLoaded(this.pets);

  @override
  List<Object?> get props => [pets];
}

class PetError extends PetState {
  final String message;

  const PetError(this.message);

  @override
  List<Object?> get props => [message];
}