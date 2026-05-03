import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pet.dart';
import '../repositories/pet_repository.dart';

class GetPets implements UseCase<List<Pet>, GetPetsParams> {
  final PetRepository repository;

  GetPets(this.repository);

  @override
  Future<Either<Failure, List<Pet>>> call(GetPetsParams params) async {
    return await repository.getPets(params.uid);
  }
}

class GetPetsParams extends Equatable {
  final String uid;

  const GetPetsParams(this.uid);

  @override
  List<Object?> get props => [uid];
}