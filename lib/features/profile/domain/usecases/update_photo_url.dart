import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_repository.dart';

class UpdatePhotoURL implements UseCase<void, UpdatePhotoURLParams> {
  final UserRepository repository;

  UpdatePhotoURL(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePhotoURLParams params) async {
    return await repository.updatePhotoURL(params.uid, params.photoURL);
  }
}

class UpdatePhotoURLParams {
  final String uid;
  final String photoURL;

  UpdatePhotoURLParams({required this.uid, required this.photoURL});
}