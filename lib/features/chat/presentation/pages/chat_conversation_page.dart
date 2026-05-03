import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../domain/entities/message.dart';

class ChatConversationPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoURL;
  final String otherUserAvatarEmoji;
  final String currentUid;

  const ChatConversationPage({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhotoURL,
    required this.otherUserAvatarEmoji,
    required this.currentUid,
  });

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(WatchMessages(
          chatId: widget.chatId,
          currentUserId: widget.currentUid,
          otherUserId: widget.otherUserId,
        ));
    _messageController.addListener(() {
      final canSend = _messageController.text.trim().isNotEmpty;
      if (canSend != _canSend) setState(() => _canSend = canSend);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(SendMessage(
          currentUserId: widget.currentUid,
          otherUserId: widget.otherUserId,
          text: text,
        ));

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is MessagesLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryPink),
                  );
                }

                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return _buildEmptyConversation(context);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == widget.currentUid;
                      final showDate = index == 0 ||
                          !_isSameDay(
                            state.messages[index - 1].createdAt,
                            message.createdAt,
                          );
                      final showAvatar = !isMe &&
                          (index == state.messages.length - 1 ||
                              state.messages[index + 1].senderId !=
                                  message.senderId);

                      return Column(
                        children: [
                          if (showDate) _DateDivider(date: message.createdAt),
                          _MessageBubble(
                            message: message,
                            isMe: isMe,
                            showAvatar: showAvatar,
                            otherUserPhotoURL: widget.otherUserPhotoURL,
                            otherUserAvatarEmoji: widget.otherUserAvatarEmoji,
                          ),
                        ],
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInputBar(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.cardColor(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary(context), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          _SmallAvatar(
            photoURL: widget.otherUserPhotoURL,
            avatarEmoji: widget.otherUserAvatarEmoji,
          ),
          const SizedBox(width: 10),
          Text(
            widget.otherUserName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        border: Border(
            top: BorderSide(color: AppTheme.borderColor(context))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle:
                      TextStyle(color: AppTheme.textSecondary(context)),
                  filled: true,
                  fillColor: AppTheme.inputBackground(context),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _canSend
                  ? AppTheme.primaryPink
                  : AppTheme.borderColor(context),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _canSend ? _sendMessage : null,
              icon: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyConversation(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '👋',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            '¡Di hola a ${widget.otherUserName}!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sois el primero en escribir',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar;
  final String? otherUserPhotoURL;
  final String otherUserAvatarEmoji;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.otherUserPhotoURL,
    required this.otherUserAvatarEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar del otro usuario
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: showAvatar
                  ? _SmallAvatar(
                      photoURL: otherUserPhotoURL,
                      avatarEmoji: otherUserAvatarEmoji,
                      size: 28,
                    )
                  : const SizedBox(width: 28),
            ),

          // Burbuja
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: isMe
                    ? AppTheme.primaryPink
                    : AppTheme.cardColor(context),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe
                            ? Colors.white
                            : AppTheme.textPrimary(context),
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withOpacity(0.75)
                          : AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;

  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Hoy';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Ayer';
    } else {
      label = DateFormat('d MMM', 'es').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: AppTheme.borderColor(context))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
              child: Divider(color: AppTheme.borderColor(context))),
        ],
      ),
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  final String? photoURL;
  final String avatarEmoji;
  final double size;

  const _SmallAvatar({
    required this.photoURL,
    required this.avatarEmoji,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: photoURL == null
            ? LinearGradient(colors: [
                AppTheme.primaryPink,
                AppTheme.primaryPink.withOpacity(0.6),
              ])
            : null,
      ),
      child: ClipOval(
        child: photoURL != null
            ? Image.network(photoURL!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                      child: Text(avatarEmoji,
                          style: TextStyle(fontSize: size * 0.45)),
                    ))
            : Center(
                child: Text(avatarEmoji,
                    style: TextStyle(fontSize: size * 0.45))),
      ),
    );
  }
}