import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet.dart';

abstract class PetRepository {
  Future<Either<Failure, List<Pet>>> getPets(String uid);
  Future<Either<Failure, Pet>> getPet(String uid, String petId);
  Future<Either<Failure, void>> addPet(String uid, Pet pet);
  Future<Either<Failure, void>> updatePet(String uid, Pet pet);
  Future<Either<Failure, void>> deletePet(String uid, String petId);
}