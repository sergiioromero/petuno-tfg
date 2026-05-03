import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<Chat>>> watchChats(String uid) {
    try {
      return remoteDataSource.watchChats(uid).map((chats) => Right(chats));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    } catch (e) {
      return Stream.value(Left(ServerFailure('Error inesperado: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<Message>>> watchMessages(String chatId) {
    try {
      return remoteDataSource
          .watchMessages(chatId)
          .map((messages) => Right(messages));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    } catch (e) {
      return Stream.value(Left(ServerFailure('Error inesperado: $e')));
    }
  }

  @override
  Future<Either<Failure, String>> sendMessage({
    required String currentUserId,
    required String otherUserId,
    required String text,
  }) async {
    try {
      final chatId = await remoteDataSource.sendMessage(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        text: text,
      );
      return Right(chatId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead({
    required String chatId,
    required String uid,
  }) async {
    try {
      await remoteDataSource.markAsRead(chatId: chatId, uid: uid);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
  }) async {
    try {
      final chatId = await remoteDataSource.getOrCreateChat(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
      );
      return Right(chatId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}