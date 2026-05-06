import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../../data/models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  late Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _likeScale = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<PostBloc>().add(
      ToggleLikePost(widget.post.id, authState.user.uid),
    );
    _likeController.forward().then((_) => _likeController.reverse());
  }

  void _openPhotoViewer(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUid =
        authState is AuthAuthenticated ? authState.user.uid : '';
    final liked = widget.post.likedBy.contains(currentUid);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => BlocProvider.value(
        value: context.read<PostBloc>(),
        child: _PhotoLightbox(
          post: widget.post,
          currentUid: currentUid,
          liked: liked,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUid = authState is AuthAuthenticated ? authState.user.uid : '';
    final liked = widget.post.likedBy.contains(currentUid);
    final bgColor = Color(int.parse(widget.post.bgColor));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [

            // Fondo: foto o emoji
            widget.post.photoURLs.isNotEmpty
                ? GestureDetector(
                    onTap: () => _openPhotoViewer(context),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.post.photoURLs[0],
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                                  ? child
                                  : Container(
                                      color: bgColor,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppTheme.primaryPink,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                        ),
                        if (widget.post.photoURLs.length > 1)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.photo_library_rounded,
                                      color: Colors.white, size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.post.photoURLs.length}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : Container(
                    color: bgColor,
                    child: Center(
                      child: Text(widget.post.petEmoji,
                          style: const TextStyle(fontSize: 110)),
                    ),
                  ),

            // Degradado inferior
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.35, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.72),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Contenido inferior de la card
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryPink.withOpacity(0.2),
                        backgroundImage: widget.post.userPhotoURL != null
                            ? NetworkImage(widget.post.userPhotoURL!)
                            : null,
                        child: widget.post.userPhotoURL == null
                            ? Text(widget.post.avatarEmoji,
                                style: const TextStyle(fontSize: 18))
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.post.userName,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          if (widget.post.petName.isNotEmpty)
                            Text(
                              '${widget.post.petName} · ${widget.post.petBreed}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (widget.post.description.isNotEmpty)
                    Text(
                      widget.post.description,
                      style: TextStyle(
                          fontSize: 13, color: Colors.white.withOpacity(0.9)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (widget.post.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: widget.post.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPink.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('#$tag',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ScaleTransition(
                        scale: _likeScale,
                        child: GestureDetector(
                          onTap: _toggleLike,
                          child: Icon(
                            liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: liked ? AppTheme.primaryPink : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text('${widget.post.likes}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(width: 16),
                      const Icon(Icons.chat_bubble_outline,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 5),
                      Text('${widget.post.comments}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const Spacer(),
                      const Icon(Icons.share_outlined,
                          color: Colors.white, size: 22),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Lightbox ─────────────────────────────────────────────────────────────────

class _PhotoLightbox extends StatefulWidget {
  final PostModel post;
  final String currentUid;
  final bool liked;

  const _PhotoLightbox({
    required this.post,
    required this.currentUid,
    required this.liked,
  });

  @override
  State<_PhotoLightbox> createState() => _PhotoLightboxState();
}

class _PhotoLightboxState extends State<_PhotoLightbox>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _likeController;
  late Animation<double> _likeScale;
  int _currentIndex = 0;
  late bool _liked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _liked = widget.liked;
    _likes = widget.post.likes;
    _pageController = PageController();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _likeScale = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _likeController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    context.read<PostBloc>().add(
      ToggleLikePost(widget.post.id, widget.currentUid),
    );
    _likeController.forward().then((_) => _likeController.reverse());
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final post = widget.post;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.05,
        vertical: screen.height * 0.12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [

            // ── Fotos con swipe ────────────────────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: post.photoURLs.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (_, i) => InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.network(
                  post.photoURLs[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primaryPink, strokeWidth: 2),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Colors.white38, size: 48),
                    ),
                  ),
                ),
              ),
            ),

            // ── Degradado inferior ─────────────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: 300,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.88),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Botón cerrar ───────────────────────────────────────────
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),

            // ── Contador de fotos ──────────────────────────────────────
            if (post.photoURLs.length > 1)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${post.photoURLs.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            // ── Info del post (abajo izquierda, sobre la foto) ─────────
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Avatar + nombre + mascota
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            AppTheme.primaryPink.withOpacity(0.25),
                        backgroundImage: post.userPhotoURL != null
                            ? NetworkImage(post.userPhotoURL!)
                            : null,
                        child: post.userPhotoURL == null
                            ? Text(post.avatarEmoji,
                                style: const TextStyle(fontSize: 18))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.userName,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                          if (post.petName.isNotEmpty)
                            Text(
                              '${post.petName} · ${post.petBreed}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Descripción
                  if (post.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      post.description,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.92),
                          height: 1.4),
                    ),
                  ],

                  // Hashtags
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: post.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primaryPink.withOpacity(0.28),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Acciones + puntos indicadores
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: ScaleTransition(
                          scale: _likeScale,
                          child: Icon(
                            _liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _liked
                                ? AppTheme.primaryPink
                                : Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('$_likes',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(width: 18),
                      const Icon(Icons.chat_bubble_outline,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 6),
                      Text('${post.comments}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const Spacer(),
                      // Puntos indicadores inline con las acciones
                      if (post.photoURLs.length > 1)
                        Row(
                          children: List.generate(
                            post.photoURLs.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _currentIndex ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: i == _currentIndex
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ),
                        )
                      else
                        const Icon(Icons.share_outlined,
                            color: Colors.white, size: 24),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
