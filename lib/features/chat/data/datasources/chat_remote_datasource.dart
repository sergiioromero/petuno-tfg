import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatModel>> watchChats(String uid);
  Stream<List<MessageModel>> watchMessages(String chatId);
  Future<String> sendMessage({
    required String currentUserId,
    required String otherUserId,
    required String text,
  });
  Future<void> markAsRead({required String chatId, required String uid});
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  /// Genera un chatId determinista a partir de los dos UIDs (orden alfabético)
  String _chatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  Stream<List<ChatModel>> watchChats(String uid) {
    try {
      return firestore
          .collection('chats')
          .where('participantIds', arrayContains: uid)
          .orderBy('lastMessageAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
    } catch (e) {
      throw ServerException('Error al obtener chats: $e');
    }
  }

  @override
  Stream<List<MessageModel>> watchMessages(String chatId) {
    try {
      return firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc, chatId))
              .toList());
    } catch (e) {
      throw ServerException('Error al obtener mensajes: $e');
    }
  }

  @override
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
  }) async {
    try {
      final chatId = _chatId(currentUserId, otherUserId);
      final ref = firestore.collection('chats').doc(chatId);
      final doc = await ref.get();

      if (!doc.exists) {
        await ref.set({
          'participantIds': [currentUserId, otherUserId],
          'lastMessage': null,
          'lastMessageAt': null,
          'lastMessageSenderId': null,
          'unreadCount': {currentUserId: 0, otherUserId: 0},
        });
      }

      return chatId;
    } catch (e) {
      throw ServerException('Error al crear chat: $e');
    }
  }

  @override
  Future<String> sendMessage({
    required String currentUserId,
    required String otherUserId,
    required String text,
  }) async {
    try {
      final chatId = await getOrCreateChat(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
      );

      final chatRef = firestore.collection('chats').doc(chatId);
      final messagesRef = chatRef.collection('messages');

      // Añadir mensaje y actualizar el chat en un batch
      final batch = firestore.batch();

      final messageDoc = messagesRef.doc();
      batch.set(messageDoc, {
        'senderId': currentUserId,
        'text': text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Actualizar metadatos del chat e incrementar unread del otro usuario
      batch.update(chatRef, {
        'lastMessage': text.trim(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageSenderId': currentUserId,
        'unreadCount.$otherUserId': FieldValue.increment(1),
      });

      await batch.commit();
      return chatId;
    } catch (e) {
      throw ServerException('Error al enviar mensaje: $e');
    }
  }

  @override
  Future<void> markAsRead({
    required String chatId,
    required String uid,
  }) async {
    try {
      await firestore.collection('chats').doc(chatId).update({
        'unreadCount.$uid': 0,
      });
    } catch (e) {
      throw ServerException('Error al marcar como leído: $e');
    }
  }
}