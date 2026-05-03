import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  /// Devuelve un stream con todos los chats del usuario actual
  Stream<Either<Failure, List<Chat>>> watchChats(String uid);

  /// Devuelve un stream con los mensajes de un chat
  Stream<Either<Failure, List<Message>>> watchMessages(String chatId);

  /// Envía un mensaje. Crea el chat si no existe.
  Future<Either<Failure, String>> sendMessage({
    required String currentUserId,
    required String otherUserId,
    required String text,
  });

  /// Marca todos los mensajes no leídos de [chatId] como leídos para [uid]
  Future<Either<Failure, void>> markAsRead({
    required String chatId,
    required String uid,
  });

  /// Obtiene o crea el chatId entre dos usuarios
  Future<Either<Failure, String>> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
  });
}