import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pet.dart';
import '../repositories/pet_repository.dart';

class GetPets implements UseCase<List<Pet>, NoParams> {
  final PetRepository repository;

  GetPets(this.repository);

  @override
  Future<Either<Failure, List<Pet>>> call(NoParams params) async {
    return await repository.getPets();
  }
}