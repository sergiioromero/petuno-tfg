import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pet_repository.dart';
import '../datasources/pet_local_datasource.dart';
import '../models/pet_model.dart';

class PetRepositoryImpl implements PetRepository {
  final PetLocalDataSource localDataSource;

  PetRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Pet>>> getPets() async {
    try {
      final petModels = await localDataSource.getPets();
      final pets = petModels.map((model) => model.toEntity()).toList();
      return Right(pets);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Pet>> getPet(String petId) async {
    try {
      final petModel = await localDataSource.getPet(petId);
      return Right(petModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addPet(Pet pet) async {
    try {
      final petModel = PetModel.fromEntity(pet);
      await localDataSource.cachePet(petModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePet(Pet pet) async {
    try {
      final petModel = PetModel.fromEntity(pet);
      await localDataSource.cachePet(petModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePet(String petId) async {
    try {
      await localDataSource.deletePet(petId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado: $e'));
    }
  }
}