import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pet.dart';
import '../repositories/pet_repository.dart';

class AddPet implements UseCase<void, AddPetParams> {
  final PetRepository repository;

  AddPet(this.repository);

  @override
  Future<Either<Failure, void>> call(AddPetParams params) async {
    return await repository.addPet(params.pet);
  }
}

class AddPetParams {
  final Pet pet;

  AddPetParams(this.pet);
}