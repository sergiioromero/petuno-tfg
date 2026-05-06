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

  // Guardamos la última lista de chats para poder restaurarla
  // cuando volvemos de una conversación
  List _lastChats = [];

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<WatchChats>(_onWatchChats);
    on<ChatsUpdated>(_onChatsUpdated);
    on<WatchMessages>(_onWatchMessages);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<SendMessage>(_onSendMessage);
    on<MarkAsRead>(_onMarkAsRead);
    on<RestoreChats>(_onRestoreChats);
  }

  Future<void> _onWatchChats(
    WatchChats event,
    Emitter<ChatState> emit,
  ) async {
    // Solo relanzamos el stream si no está ya activo
    if (_chatsSubscription != null) {
      // El stream ya existe — solo restauramos el estado de chats
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
    // NO cancelamos _chatsSubscription — sigue corriendo en segundo plano
    await _messagesSubscription?.cancel();

    _activeChatId = event.chatId;

    emit(ChatLoading());

    // Aseguramos que el documento del chat existe antes de escuchar
    final chatResult = await chatRepository.getOrCreateChat(
      currentUserId: event.currentUserId,
      otherUserId: event.otherUserId,
    );

    if (chatResult.isLeft()) {
      emit(const ChatError('No se pudo iniciar el chat'));
      return;
    }

    // Marcar como leído al abrir
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

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<ChatState> emit,
  ) async {
    await chatRepository.markAsRead(
      chatId: event.chatId,
      uid: event.uid,
    );
  }

  // Restaurar la lista de chats al volver de una conversación
  void _onRestoreChats(RestoreChats event, Emitter<ChatState> emit) {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    emit(ChatsLoaded(List.from(_lastChats)));
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}