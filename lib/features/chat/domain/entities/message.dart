import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;
  final bool deleted;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.createdAt,
    this.isRead = false,
    this.deleted = false,
  });

  bool get isImage => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  List<Object?> get props =>
      [id, chatId, senderId, text, imageUrl, createdAt, isRead, deleted];
}