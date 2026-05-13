import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/post_model.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  int _retryKey = 0;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    _commentController.clear();
    context.read<PostBloc>().add(AddComment(
          postId: widget.post.id,
          uid: authState.user.uid,
          userName: authState.user.displayName ?? 'Usuario',
          userPhotoURL: authState.user.photoURL,
          text: text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUid = authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary(context), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Publicación',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              key: ValueKey('comments_$_retryKey'),
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.post.id)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots()
                  .map((snap) => snap.docs
                      .map((d) => CommentModel.fromFirestore(d, widget.post.id))
                      .toList()),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildError(
                    context,
                    error: snapshot.error,
                    onRetry: () => setState(() => _retryKey++),
                  );
                }

                final comments = snapshot.data ?? [];

                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryPink));
                }

                if (comments.isEmpty) {
                  return ListView(
                    children: [
                      _buildPostHeader(context),
                      _buildPostContent(context),
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 48,
                                  color: AppTheme.textSecondary(context)
                                      .withOpacity(0.4)),
                              const SizedBox(height: 16),
                              Text(
                                'No hay comentarios aún',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '¡Sé el primero en comentar!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return ListView(
                  controller: _scrollController,
                  children: [
                    _buildPostHeader(context),
                    _buildPostContent(context),
                    const Divider(height: 1),
                    ...comments.map(
                      (c) => _CommentTile(
                        comment: c,
                        currentUid: currentUid,
                        onDelete: () {
                          context
                              .read<PostBloc>()
                              .add(DeleteComment(widget.post.id, c.id));
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          _buildCommentInput(context),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context,
      {required Object? error, required VoidCallback onRetry}) {
    String msg = 'Error al cargar los comentarios';
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          msg = 'No tienes permiso para ver los comentarios';
          break;
        case 'unavailable':
          msg = 'Servicio no disponible. Comprueba tu conexión';
          break;
        case 'not-found':
          msg = 'Publicación no encontrada';
          break;
        default:
          msg = error.message ?? 'Error de Firestore: ${error.code}';
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 36, color: AppTheme.primaryPink),
            ),
            const SizedBox(height: 20),
            Text(
              'Algo salió mal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    final post = widget.post;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryPink.withOpacity(0.2),
            backgroundImage:
                post.userPhotoURL != null ? NetworkImage(post.userPhotoURL!) : null,
            child: post.userPhotoURL == null
                ? Text(post.avatarEmoji, style: const TextStyle(fontSize: 20))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.userName,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary(context))),
                if (post.petName.isNotEmpty)
                  Text('${post.petName} · ${post.petBreed}',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(BuildContext context) {
    final post = widget.post;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.photoURLs.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: post.photoURLs.length > 1
                    ? PageView.builder(
                        itemCount: post.photoURLs.length,
                        itemBuilder: (_, i) => Image.network(
                          post.photoURLs[i],
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(
                                          color: AppTheme.primaryPink,
                                          strokeWidth: 2)),
                          errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image_outlined,
                                  color: Colors.white38, size: 48)),
                        ),
                      )
                    : Image.network(
                        post.photoURLs[0],
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) =>
                            progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator(
                                        color: AppTheme.primaryPink,
                                        strokeWidth: 2)),
                        errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image_outlined,
                                color: Colors.white38, size: 48)),
                      ),
              ),
            ),
          if (post.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(post.description,
                style: TextStyle(
                    fontSize: 14, color: AppTheme.textPrimary(context))),
          ],
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: post.tags
                  .map((tag) => Text('#$tag',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryPink)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${post.likes} me gusta',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary(context))),
              const SizedBox(width: 16),
              Text('${post.comments} comentarios',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary(context))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        border: Border(
            top: BorderSide(color: AppTheme.borderColor(context), width: 0.5)),
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Escribe un comentario...',
                hintStyle:
                    TextStyle(color: AppTheme.textSecondary(context)),
                filled: true,
                fillColor: AppTheme.backgroundColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 14),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendComment(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendComment,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final String currentUid;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.currentUid,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = comment.uid == currentUid;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryPink.withOpacity(0.15),
            backgroundImage: comment.userPhotoURL != null
                ? NetworkImage(comment.userPhotoURL!)
                : null,
            child: comment.userPhotoURL == null
                ? Text('👤', style: const TextStyle(fontSize: 16))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(comment.userName,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary(context))),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(comment.createdAt),
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary(context)),
                      ),
                      if (isOwner) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: onDelete,
                          child: Icon(Icons.delete_outline_rounded,
                              size: 16,
                              color: AppTheme.textSecondary(context)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.text,
                      style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary(context))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
