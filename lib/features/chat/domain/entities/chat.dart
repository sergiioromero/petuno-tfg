import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount; // uid -> cantidad no leídos

  const Chat({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.unreadCount = const {},
  });

  @override
  List<Object?> get props => [
        id,
        participantIds,
        lastMessage,
        lastMessageAt,
        lastMessageSenderId,
        unreadCount,
      ];
}