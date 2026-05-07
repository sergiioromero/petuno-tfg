import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  StreamSubscription? _chatsSubscription;
  StreamSubscription? _messagesSubscription;

  String _activeChatId = '';
  List _lastChats = [];

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<WatchChats>(_onWatchChats);
    on<ChatsUpdated>(_onChatsUpdated);
    on<WatchMessages>(_onWatchMessages);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<SendMessage>(_onSendMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<MarkAsRead>(_onMarkAsRead);
    on<DeleteMessage>(_onDeleteMessage);
    on<DeleteChat>(_onDeleteChat);
    on<RestoreChats>(_onRestoreChats);
    on<StopAllStreams>(_onStopAllStreams);
  }

  Future<void> _onWatchChats(
    WatchChats event,
    Emitter<ChatState> emit,
  ) async {
    if (_chatsSubscription != null) {
      emit(ChatsLoaded(List.from(_lastChats)));
      return;
    }

    emit(ChatLoading());

    _chatsSubscription = chatRepository.watchChats(event.uid).listen(
      (result) {
        result.fold(
          (failure) => add(ChatsUpdated([])),
          (chats) => add(ChatsUpdated(chats)),
        );
      },
    );
  }

  void _onChatsUpdated(ChatsUpdated event, Emitter<ChatState> emit) {
    _lastChats = event.chats;
    emit(ChatsLoaded(event.chats));
  }

  Future<void> _onWatchMessages(
    WatchMessages event,
    Emitter<ChatState> emit,
  ) async {
    await _messagesSubscription?.cancel();

    _activeChatId = event.chatId;

    emit(ChatLoading());

    final chatResult = await chatRepository.getOrCreateChat(
      currentUserId: event.currentUserId,
      otherUserId: event.otherUserId,
    );

    if (chatResult.isLeft()) {
      emit(const ChatError('No se pudo iniciar el chat'));
      return;
    }

    chatRepository.markAsRead(chatId: event.chatId, uid: event.currentUserId);

    _messagesSubscription = chatRepository.watchMessages(event.chatId).listen(
      (result) {
        result.fold(
          (failure) => emit(ChatError(failure.message)),
          (messages) => add(MessagesUpdated(messages)),
        );
      },
    );
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    emit(MessagesLoaded(messages: event.messages, chatId: _activeChatId));
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    await chatRepository.sendMessage(
      currentUserId: event.currentUserId,
      otherUserId: event.otherUserId,
      text: event.text,
    );
  }

  Future<void> _onSendImageMessage(
    SendImageMessage event,
    Emitter<ChatState> emit,
  ) async {
    await chatRepository.sendImageMessage(
      currentUserId: event.currentUserId,
      otherUserId: event.otherUserId,
      imagePath: event.imagePath,
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<ChatState> emit,
  ) async {
    await chatRepository.markAsRead(
      chatId: event.chatId,
      uid: event.uid,
    );
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    await chatRepository.deleteMessage(
      chatId: event.chatId,
      messageId: event.messageId,
    );
  }

  Future<void> _onDeleteChat(
    DeleteChat event,
    Emitter<ChatState> emit,
  ) async {
    await chatRepository.deleteChat(
      chatId: event.chatId,
      uid: event.uid,
    );
    // El StreamBuilder de chat_list_page se actualizará solo al cambiar Firestore
  }

  void _onRestoreChats(RestoreChats event, Emitter<ChatState> emit) {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    emit(ChatsLoaded(List.from(_lastChats)));
  }

  Future<void> _onStopAllStreams(
    StopAllStreams event,
    Emitter<ChatState> emit,
  ) async {
    await _chatsSubscription?.cancel();
    await _messagesSubscription?.cancel();
    _chatsSubscription = null;
    _messagesSubscription = null;
    _lastChats = [];
    emit(ChatInitial());
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}