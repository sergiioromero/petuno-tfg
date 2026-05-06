import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool _liked = false;
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
    setState(() => _liked = !_liked);
    _likeController.forward().then((_) => _likeController.reverse());
  }

  @override
  Widget build(BuildContext context) {
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

            // ── Fondo: foto del animal (emoji simulado) ──────────────
            Container(
              color: widget.post['bgColor'],
              child: Center(
                child: Text(
                  widget.post['petEmoji'],
                  style: const TextStyle(fontSize: 110),
                ),
              ),
            ),

            // ── Degradado inferior ───────────────────────────────────
            Positioned.fill(
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

            // ── Match badge (esquina superior derecha) ───────────────
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pets,
                        size: 13, color: AppTheme.primaryPink),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post['match']}% match',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Contenido inferior ───────────────────────────────────
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Perfil del dueño + nombre del animal
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            AppTheme.primaryPink.withOpacity(0.2),
                        child: Text(
                          widget.post['avatar'],
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post['user'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.post['petName'],
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

                  // Descripción
                  Text(
                    widget.post['description'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Hashtags
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: (widget.post['tags'] as List<String>)
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPink.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 12),

                  // Likes, comentarios y compartir
                  Row(
                    children: [
                      // Like con animación
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
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${widget.post['likes'] + (_liked ? 1 : 0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Comentarios
                      GestureDetector(
                        onTap: () {
                          // TODO: abrir comentarios
                        },
                        child: const Icon(Icons.chat_bubble_outline,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${widget.post['comments']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      const Spacer(),

                      // Compartir
                      GestureDetector(
                        onTap: () {
                          // TODO: compartir post
                        },
                        child: const Icon(Icons.share_outlined,
                            color: Colors.white, size: 22),
                      ),
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