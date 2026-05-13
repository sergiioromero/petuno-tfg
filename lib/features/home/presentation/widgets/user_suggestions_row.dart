import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_navigation.dart';
import '../../../../features/profile/data/models/user_model.dart';
import '../../../../features/profile/domain/entities/user.dart' as domain;
import '../../../../features/profile/presentation/pages/user_profile_page.dart';
import '../../../../features/chat/presentation/bloc/chat_bloc.dart';

class UserSuggestionsRow extends StatefulWidget {
  const UserSuggestionsRow({super.key});

  @override
  State<UserSuggestionsRow> createState() => _UserSuggestionsRowState();
}

class _UserSuggestionsRowState extends State<UserSuggestionsRow> {
  List<domain.User> _suggestions = [];
  bool _loading = true;
  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .limit(20)
          .get();

      final users = snapshot.docs
          .where((doc) => doc.id != currentUid)
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      if (mounted) {
        setState(() {
          _suggestions = users;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragAngle = _dragOffset.dx * 0.001;
      _isDragging = true;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset.dx.abs() > 100 && _suggestions.isNotEmpty) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _suggestions.length;
      });
    }
    setState(() {
      _dragOffset = Offset.zero;
      _dragAngle = 0;
      _isDragging = false;
    });
  }

  void _goToMatching(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigation(initialIndex: 2),
      ),
      (route) => false,
    );
  }

  void _openUserProfile(BuildContext context, domain.User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChatBloc>(),
          child: UserProfilePage(userId: user.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sugerencias para ti',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              GestureDetector(
                onTap: () => _goToMatching(context),
                child: Text(
                  'Ver más',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (_loading)
          const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_suggestions.isEmpty)
          SizedBox(
            height: 180,
            child: Center(
              child: Text(
                'No hay sugerencias por ahora',
                style: TextStyle(color: AppTheme.textSecondary(context)),
              ),
            ),
          )
        else ...[
          Center(
            child: SizedBox(
              height: 180,
              width: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_suggestions.length > 2)
                    _buildCard(
                      context,
                      _suggestions[(_currentIndex + 2) % _suggestions.length],
                      scale: 0.88,
                      yOffset: 16,
                      opacity: 0.5,
                      draggable: false,
                    ),
                  if (_suggestions.length > 1)
                    _buildCard(
                      context,
                      _suggestions[(_currentIndex + 1) % _suggestions.length],
                      scale: 0.94,
                      yOffset: 8,
                      opacity: 0.75,
                      draggable: false,
                    ),
                  GestureDetector(
                    onTap: () => _openUserProfile(
                        context, _suggestions[_currentIndex]),
                    onPanUpdate: _onDragUpdate,
                    onPanEnd: _onDragEnd,
                    child: AnimatedContainer(
                      duration: _isDragging
                          ? Duration.zero
                          : const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      transform: Matrix4.identity()
                        ..translate(_dragOffset.dx, _dragOffset.dy)
                        ..rotateZ(_dragAngle),
                      transformAlignment: Alignment.bottomCenter,
                      child: Stack(
                        children: [
                          _buildCard(
                            context,
                            _suggestions[_currentIndex],
                            scale: 1.0,
                            yOffset: 0,
                            opacity: 1.0,
                            draggable: true,
                          ),
                          if (_isDragging && _dragOffset.dx < -30)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity:
                                    ((-_dragOffset.dx - 30) / 70).clamp(0.0, 1.0),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.close_rounded,
                                      color: Colors.redAccent, size: 22),
                                ),
                              ),
                            ),
                          if (_isDragging && _dragOffset.dx > 30)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity:
                                    ((_dragOffset.dx - 30) / 70).clamp(0.0, 1.0),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.favorite_rounded,
                                      color: AppTheme.primaryPink, size: 22),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _suggestions.length.clamp(0, 5),
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentIndex % _suggestions.length.clamp(1, 5)
                    ? 18
                    : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color:
                      i == _currentIndex % _suggestions.length.clamp(1, 5)
                          ? AppTheme.primaryPink
                          : const Color(0xFFDDDDDD),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    domain.User user, {
    required double scale,
    required double yOffset,
    required double opacity,
    required bool draggable,
  }) {
    // Paleta de colores de fondo para cuando no hay foto
    final bgColors = [
      const Color(0xFFFFF3E0),
      const Color(0xFFE8F5E9),
      const Color(0xFFF3E5F5),
      const Color(0xFFE3F2FD),
      const Color(0xFFFCE4EC),
    ];
    final bgColor = bgColors[user.id.hashCode.abs() % bgColors.length];
    final hasPhoto = user.photoURL != null && user.photoURL!.isNotEmpty;

    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 280,
            height: 160,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
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
                  // Foto de perfil o avatar emoji
                  if (hasPhoto)
                    Image.network(
                      user.photoURL!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(user.avatarEmoji,
                            style: const TextStyle(fontSize: 72)),
                      ),
                    )
                  else
                    Center(
                      child: Text(user.avatarEmoji,
                          style: const TextStyle(fontSize: 72)),
                    ),

                  // Degradado inferior
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.45, 1.0],
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.60),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Info inferior
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name.isNotEmpty ? user.name : 'Usuario',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (user.location.isNotEmpty)
                                Text(
                                  user.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Ver perfil',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}