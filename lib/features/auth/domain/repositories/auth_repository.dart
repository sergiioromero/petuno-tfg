import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> register({
    required String email,
    required String password,
    required String name,
    required DateTime birthDate,
  });

  Future<Either<Failure, AuthUser>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, AuthUser?>> getCurrentUser();

  Stream<AuthUser?> get authStateChanges;
}