import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pet.dart';
import '../repositories/pet_repository.dart';

class UpdatePet implements UseCase<void, UpdatePetParams> {
  final PetRepository repository;

  UpdatePet(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePetParams params) async {
    return await repository.updatePet(params.pet);
  }
}

class UpdatePetParams {
  final Pet pet;

  UpdatePetParams(this.pet);
}