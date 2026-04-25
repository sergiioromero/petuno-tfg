import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/pet_repository.dart';

class DeletePet implements UseCase<void, DeletePetParams> {
  final PetRepository repository;

  DeletePet(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePetParams params) async {
    return await repository.deletePet(params.petId);
  }
}

class DeletePetParams {
  final String petId;

  DeletePetParams(this.petId);
}