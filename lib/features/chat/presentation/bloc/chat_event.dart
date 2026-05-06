import 'package:equatable/equatable.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class WatchChats extends ChatEvent {
  final String uid;
  const WatchChats(this.uid);

  @override
  List<Object?> get props => [uid];
}

class ChatsUpdated extends ChatEvent {
  final List<Chat> chats;
  const ChatsUpdated(this.chats);

  @override
  List<Object?> get props => [chats];
}

class WatchMessages extends ChatEvent {
  final String chatId;
  final String currentUserId;
  final String otherUserId;

  const WatchMessages({
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
  });

  @override
  List<Object?> get props => [chatId, currentUserId, otherUserId];
}

class MessagesUpdated extends ChatEvent {
  final List<Message> messages;
  const MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

class SendMessage extends ChatEvent {
  final String currentUserId;
  final String otherUserId;
  final String text;

  const SendMessage({
    required this.currentUserId,
    required this.otherUserId,
    required this.text,
  });

  @override
  List<Object?> get props => [currentUserId, otherUserId, text];
}

class SendImageMessage extends ChatEvent {
  final String currentUserId;
  final String otherUserId;
  final String imagePath;

  const SendImageMessage({
    required this.currentUserId,
    required this.otherUserId,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [currentUserId, otherUserId, imagePath];
}

class MarkAsRead extends ChatEvent {
  final String chatId;
  final String uid;
  const MarkAsRead({required this.chatId, required this.uid});

  @override
  List<Object?> get props => [chatId, uid];
}

/// Restaura la lista de chats al volver de una conversación
class RestoreChats extends ChatEvent {}

class StopAllStreams extends ChatEvent {}