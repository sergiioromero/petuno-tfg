import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Stream<Either<Failure, List<Chat>>> watchChats(String uid);
  Stream<Either<Failure, List<Message>>> watchMessages(String chatId);

  Future<Either<Failure, String>> sendMessage({
    required String currentUserId,
    required String otherUserId,
    required String text,
  });

  Future<Either<Failure, String>> sendImageMessage({
    required String currentUserId,
    required String otherUserId,
    required String imagePath,
  });

  Future<Either<Failure, void>> markAsRead({
    required String chatId,
    required String uid,
  });

  Future<Either<Failure, String>> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
  });

  Future<Either<Failure, void>> deleteMessage({
    required String chatId,
    required String messageId,
  });

  Future<Either<Failure, void>> deleteChat({
    required String chatId,
    required String uid,
  });
}