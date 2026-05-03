import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_conversation_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ChatBloc>().add(WatchChats(authState.user.uid));
    }
  }

  String get _currentUid {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.uid : '';
  }

  void _openNewChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ChatBloc>(),
        child: _NewChatSheet(currentUid: _currentUid),
      ),
    ).then((_) {
      // Al cerrar el sheet restauramos el estado de chats
      if (mounted) {
        context.read<ChatBloc>().add(RestoreChats());
      }
    });
  }

  void _openConversation({
    required String chatId,
    required String otherUserId,
    required String otherUserName,
    required String? otherUserPhotoURL,
    required String otherUserAvatarEmoji,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChatBloc>(),
          child: ChatConversationPage(
            chatId: chatId,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            otherUserPhotoURL: otherUserPhotoURL,
            otherUserAvatarEmoji: otherUserAvatarEmoji,
            currentUid: _currentUid,
          ),
        ),
      ),
    ).then((_) {
      // Al volver de la conversación, restauramos la lista de chats
      if (mounted) {
        context.read<ChatBloc>().add(RestoreChats());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor(context),
        elevation: 0,
        title: Text(
          'Mensajes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary(context),
            letterSpacing: -0.5,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewChatSheet,
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            );
          }

          if (state is ChatError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: TextStyle(color: AppTheme.textSecondary(context)),
              ),
            );
          }

          if (state is ChatsLoaded) {
            if (state.chats.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.separated(
              itemCount: state.chats.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppTheme.borderColor(context),
                indent: 80,
              ),
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                final otherUserId = chat.participantIds
                    .firstWhere((id) => id != _currentUid, orElse: () => '');
                final unread = chat.unreadCount[_currentUid] ?? 0;

                return _ChatTile(
                  chatId: chat.id,
                  otherUserId: otherUserId,
                  lastMessage: chat.lastMessage,
                  lastMessageAt: chat.lastMessageAt,
                  unreadCount: unread,
                  isLastMessageMine: chat.lastMessageSenderId == _currentUid,
                  currentUid: _currentUid,
                  onTap: (name, photoURL, avatarEmoji) => _openConversation(
                    chatId: chat.id,
                    otherUserId: otherUserId,
                    otherUserName: name,
                    otherUserPhotoURL: photoURL,
                    otherUserAvatarEmoji: avatarEmoji,
                  ),
                );
              },
            );
          }

          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 72,
            color: AppTheme.textSecondary(context).withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin mensajes aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pulsa el botón para empezar\nuna conversación',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Icon(
            Icons.arrow_downward_rounded,
            color: AppTheme.primaryPink.withOpacity(0.5),
            size: 28,
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet para buscar usuario y abrir chat ────────────────────────────

class _NewChatSheet extends StatefulWidget {
  final String currentUid;

  const _NewChatSheet({required this.currentUid});

  @override
  State<_NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends State<_NewChatSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _loading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(20)
          .get();

      final results = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .where((u) => u['id'] != widget.currentUid)
          .toList();

      setState(() {
        _results = List<Map<String, dynamic>>.from(results);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _openChat(Map<String, dynamic> user) {
    final otherUid = user['id'] as String;
    final name = user['name'] ?? '';
    final photoURL = user['photoURL'] as String?;
    final avatarEmoji = user['avatarEmoji'] ?? '👤';

    final sorted = [widget.currentUid, otherUid]..sort();
    final chatId = '${sorted[0]}_${sorted[1]}';

    Navigator.pop(context); // cierra el sheet

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChatBloc>(),
          child: ChatConversationPage(
            chatId: chatId,
            otherUserId: otherUid,
            otherUserName: name,
            otherUserPhotoURL: photoURL,
            otherUserAvatarEmoji: avatarEmoji,
            currentUid: widget.currentUid,
          ),
        ),
      ),
    ).then((_) {
      // Al volver restauramos la lista de chats
      if (context.mounted) {
        context.read<ChatBloc>().add(RestoreChats());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Nuevo mensaje',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  onChanged: _search,
                  style: TextStyle(color: AppTheme.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre...',
                    hintStyle:
                        TextStyle(color: AppTheme.textSecondary(context)),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppTheme.textSecondary(context)),
                    filled: true,
                    fillColor: AppTheme.inputBackground(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryPink),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isEmpty
                                  ? 'Escribe un nombre para buscar'
                                  : 'Sin resultados',
                              style: TextStyle(
                                color: AppTheme.textSecondary(context),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final user = _results[index];
                              final photoURL = user['photoURL'] as String?;
                              final avatarEmoji = user['avatarEmoji'] ?? '👤';

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 4),
                                leading: _Avatar(
                                  photoURL: photoURL,
                                  avatarEmoji: avatarEmoji,
                                  size: 46,
                                ),
                                title: Text(
                                  user['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                                subtitle: Text(
                                  user['location'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                                onTap: () => _openChat(user),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Chat tile ────────────────────────────────────────────────────────────────

class _ChatTile extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isLastMessageMine;
  final String currentUid;
  final void Function(String name, String? photoURL, String avatarEmoji) onTap;

  const _ChatTile({
    required this.chatId,
    required this.otherUserId,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.isLastMessageMine,
    required this.currentUid,
    required this.onTap,
  });

  Future<Map<String, dynamic>?> _fetchUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(otherUserId),
      builder: (context, snapshot) {
        final name = snapshot.data?['name'] ?? '...';
        final photoURL = snapshot.data?['photoURL'] as String?;
        final avatarEmoji = snapshot.data?['avatarEmoji'] ?? '👤';

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: _Avatar(
            photoURL: photoURL,
            avatarEmoji: avatarEmoji,
            size: 52,
          ),
          title: Text(
            name,
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
              color: AppTheme.textPrimary(context),
            ),
          ),
          subtitle: Row(
            children: [
              if (isLastMessageMine)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: AppTheme.primaryPink,
                  ),
                ),
              Expanded(
                child: Text(
                  lastMessage ?? 'Inicia la conversación',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: unreadCount > 0
                        ? AppTheme.textPrimary(context)
                        : AppTheme.textSecondary(context),
                    fontWeight: unreadCount > 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (lastMessageAt != null)
                Text(
                  timeago.format(lastMessageAt!, locale: 'es'),
                  style: TextStyle(
                    fontSize: 11,
                    color: unreadCount > 0
                        ? AppTheme.primaryPink
                        : AppTheme.textSecondary(context),
                    fontWeight: unreadCount > 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              if (unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: () => onTap(name, photoURL, avatarEmoji),
        );
      },
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? photoURL;
  final String avatarEmoji;
  final double size;

  const _Avatar({
    required this.photoURL,
    required this.avatarEmoji,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: photoURL == null
            ? LinearGradient(
                colors: [
                  AppTheme.primaryPink,
                  AppTheme.primaryPink.withOpacity(0.6),
                ],
              )
            : null,
      ),
      child: ClipOval(
        child: photoURL != null
            ? Image.network(
                photoURL!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(avatarEmoji,
                      style: TextStyle(fontSize: size * 0.45)),
                ),
              )
            : Center(
                child: Text(avatarEmoji,
                    style: TextStyle(fontSize: size * 0.45)),
              ),
      ),
    );
  }
}