import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/cloudinary_service.dart';
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
  Future<String> sendImageMessage({
    required String currentUserId,
    required String otherUserId,
    required String imagePath,
  });
  Future<void> markAsRead({required String chatId, required String uid});
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
  });
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final CloudinaryService cloudinaryService;

  ChatRemoteDataSourceImpl({
    required this.firestore,
    required this.cloudinaryService,
  });

  String _chatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> _sendNotification({
    required String recipientId,
    required String senderId,
    required String type,
    required String message,
  }) async {
    try {
      final senderDoc =
          await firestore.collection('users').doc(senderId).get();
      final senderData = senderDoc.data() ?? {};
      final fromName = senderData['name'] ?? 'Alguien';
      final fromPhotoURL = senderData['photoURL'] as String?;

      await firestore
          .collection('notifications')
          .doc(recipientId)
          .collection('items')
          .add({
        'type': type,
        'fromName': fromName,
        'fromPhotoURL': fromPhotoURL,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (_) {}
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
          'lastMessageId': null,
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
      final messageDoc = messagesRef.doc();

      final batch = firestore.batch();

      batch.set(messageDoc, {
        'senderId': currentUserId,
        'text': text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'deleted': false,
      });

      batch.update(chatRef, {
        'lastMessage': text.trim(),
        'lastMessageId': messageDoc.id,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageSenderId': currentUserId,
        'unreadCount.$otherUserId': FieldValue.increment(1),
      });

      await batch.commit();

      await _sendNotification(
        recipientId: otherUserId,
        senderId: currentUserId,
        type: 'message',
        message: 'te envió un mensaje',
      );

      return chatId;
    } catch (e) {
      throw ServerException('Error al enviar mensaje: $e');
    }
  }

  @override
  Future<String> sendImageMessage({
    required String currentUserId,
    required String otherUserId,
    required String imagePath,
  }) async {
    try {
      final imageUrl = await cloudinaryService.uploadImage(
        imagePath,
        folder: 'chat_images',
      );

      final chatId = await getOrCreateChat(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
      );

      final chatRef = firestore.collection('chats').doc(chatId);
      final messagesRef = chatRef.collection('messages');
      final messageDoc = messagesRef.doc();

      final batch = firestore.batch();

      batch.set(messageDoc, {
        'senderId': currentUserId,
        'text': '',
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'deleted': false,
      });

      batch.update(chatRef, {
        'lastMessage': '📷 Foto',
        'lastMessageId': messageDoc.id,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageSenderId': currentUserId,
        'unreadCount.$otherUserId': FieldValue.increment(1),
      });

      await batch.commit();

      await _sendNotification(
        recipientId: otherUserId,
        senderId: currentUserId,
        type: 'message',
        message: 'te envió una foto',
      );

      return chatId;
    } catch (e) {
      throw ServerException('Error al enviar imagen: $e');
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

  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      final chatRef = firestore.collection('chats').doc(chatId);
      final messageRef = chatRef.collection('messages').doc(messageId);

      await messageRef.update({'deleted': true, 'text': '', 'imageUrl': null});

      final chatDoc = await chatRef.get();
      final lastMessageId = chatDoc.data()?['lastMessageId'] as String?;
      if (lastMessageId == messageId) {
        await chatRef.update({'lastMessage': 'Mensaje eliminado'});
      }
    } catch (e) {
      throw ServerException('Error al eliminar mensaje: $e');
    }
  }
}