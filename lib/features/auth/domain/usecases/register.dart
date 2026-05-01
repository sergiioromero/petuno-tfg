import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class Register implements UseCase<AuthUser, RegisterParams> {
  final AuthRepository repository;

  Register(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
      birthDate: params.birthDate,
    );
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String name;
  final DateTime birthDate;

  RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.birthDate,
  });
}