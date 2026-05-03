import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pet_repository.dart';
import '../datasources/pet_remote_datasource.dart';
import '../models/pet_model.dart';

class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource remoteDataSource;

  PetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Pet>>> getPets(String uid) async {
    try {
      final petModels = await remoteDataSource.getPets(uid);
      final pets = petModels.map((model) => model.toEntity()).toList();
      return Right(pets);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Pet>> getPet(String uid, String petId) async {
    try {
      final pets = await remoteDataSource.getPets(uid);
      final pet = pets.firstWhere(
        (p) => p.id == petId,
        orElse: () => throw ServerException('Mascota no encontrada'),
      );
      return Right(pet.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addPet(String uid, Pet pet) async {
    try {
      final petModel = PetModel.fromEntity(pet);
      await remoteDataSource.addPet(uid, petModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePet(String uid, Pet pet) async {
    try {
      final petModel = PetModel.fromEntity(pet);
      await remoteDataSource.updatePet(uid, petModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePet(String uid, String petId) async {
    try {
      await remoteDataSource.deletePet(uid, petId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}