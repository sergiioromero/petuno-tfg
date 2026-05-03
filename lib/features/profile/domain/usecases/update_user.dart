import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class UpdateUser implements UseCase<void, UpdateUserParams> {
  final UserRepository repository;

  UpdateUser(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserParams params) async {
    return await repository.updateUser(params.user);
  }
}

class UpdateUserParams {
  final User user;

  UpdateUserParams(this.user);
}