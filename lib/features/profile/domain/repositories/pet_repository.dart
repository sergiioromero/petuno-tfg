import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet.dart';

abstract class PetRepository {
  Future<Either<Failure, List<Pet>>> getPets();
  Future<Either<Failure, Pet>> getPet(String petId);
  Future<Either<Failure, void>> addPet(Pet pet);
  Future<Either<Failure, void>> updatePet(Pet pet);
  Future<Either<Failure, void>> deletePet(String petId);
}