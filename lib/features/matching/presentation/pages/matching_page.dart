import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../widgets/swipe_card.dart';
import '../widgets/match_item.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage>
    with SingleTickerProviderStateMixin {
  // Datos de ejemplo para swipe — TODO: reemplazar con backend
  final List<Map<String, dynamic>> _candidates = [
    {
      'name': 'Sofía',
      'age': 28,
      'ownerAvatar': '👩',
      'petEmoji': '🐕',
      'bgColor': const Color(0xFFFFF3E0),
      'distance': '1.2 km',
      'match': 94,
      'bio': 'Amante de los perros y los paseos al aire libre 🌳',
      'interests': ['Parques', 'Senderismo', 'Fotografía'],
    },
    {
      'name': 'Carlos',
      'age': 32,
      'ownerAvatar': '👨',
      'petEmoji': '🐈',
      'bgColor': const Color(0xFFE8F5E9),
      'distance': '2.5 km',
      'match': 89,
      'bio': 'Mis gatos son mi vida, busco amigos gatunos 🐱',
      'interests': ['Gatos', 'Cine', 'Cocina'],
    },
    {
      'name': 'Elena',
      'age': 25,
      'ownerAvatar': '🧑',
      'petEmoji': '🐇',
      'bgColor': const Color(0xFFF3E5F5),
      'distance': '3.8 km',
      'match': 82,
      'bio': 'Criadora de conejos enanos, me encanta la naturaleza',
      'interests': ['Naturaleza', 'Lectura', 'Yoga'],
    },
  ];

  // Datos de ejemplo para matches — TODO: reemplazar con backend
  final List<Map<String, dynamic>> _matches = [
    {
      'name': 'Laura',
      'petEmoji': '🐕',
      'bgColor': const Color(0xFFFCE4EC),
      'match': 91,
      'lastMessage': '¡Sí! Vamos al parque el sábado 🎉',
      'time': '10:30',
      'unread': 2,
    },
    {
      'name': 'Miguel',
      'petEmoji': '🦜',
      'bgColor': const Color(0xFFE3F2FD),
      'match': 87,
      'lastMessage': 'Mi loro también habla mucho jaja',
      'time': 'Ayer',
      'unread': 0,
    },
    {
      'name': 'Ana',
      'petEmoji': '🐈',
      'bgColor': const Color(0xFFF1F8E9),
      'match': 85,
      'lastMessage': 'Gracias por el consejo!',
      'time': '2d',
      'unread': 0,
    },
  ];

  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0;
  bool _isDragging = false;
  late AnimationController _removeController;

  @override
  void initState() {
    super.initState();
    _removeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _removeController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragAngle = _dragOffset.dx * 0.002;
      _isDragging = true;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset.dx.abs() > 120) {
      // Swipe completado
      final isLike = _dragOffset.dx > 0;
      _animateRemoval(isLike);
    } else {
      // Volver al centro
      setState(() {
        _dragOffset = Offset.zero;
        _dragAngle = 0;
        _isDragging = false;
      });
    }
  }

  void _animateRemoval(bool isLike) {
    setState(() {
      _dragOffset = Offset(_dragOffset.dx > 0 ? 400 : -400, _dragOffset.dy);
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _candidates.length;
          _dragOffset = Offset.zero;
          _dragAngle = 0;
          _isDragging = false;
        });

        if (isLike) {
          _showMatchSnackbar();
        }
      }
    });
  }

  void _showMatchSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.favorite, color: AppTheme.primaryPink, size: 20),
            const SizedBox(width: 8),
            const Text('¡Es un match! 🎉'),
          ],
        ),
        backgroundColor: AppTheme.cardColor(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Descubre',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary(context),
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Swipe cards
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Tarjeta fondo +1
                    if (_candidates.length > 1)
                      Transform.scale(
                        scale: 0.92,
                        child: Opacity(
                          opacity: 0.5,
                          child: SwipeCard(
                            user: _candidates[
                                (_currentIndex + 1) % _candidates.length],
                          ),
                        ),
                      ),

                    // Tarjeta principal
                    GestureDetector(
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
                            SwipeCard(user: _candidates[_currentIndex]),

                            // Indicador X izquierda
                            if (_isDragging && _dragOffset.dx < -40)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Colors.redAccent,
                                      width: 5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: -0.3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.redAccent,
                                            width: 4,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'NOPE',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // Indicador corazón derecha
                            if (_isDragging && _dragOffset.dx > 40)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: AppTheme.primaryPink,
                                      width: 5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: 0.3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppTheme.primaryPink,
                                            width: 4,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'LIKE',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.primaryPink,
                                          ),
                                        ),
                                      ),
                                    ),
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

            const SizedBox(height: 16),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón rechazar
                  _buildActionButton(
                    icon: Icons.close_rounded,
                    color: Colors.redAccent,
                    onTap: () => _animateRemoval(false),
                  ),

                  // Botón like
                  _buildActionButton(
                    icon: Icons.favorite_rounded,
                    color: AppTheme.primaryPink,
                    size: 70,
                    iconSize: 36,
                    onTap: () => _animateRemoval(true),
                  ),

                  // Botón super like
                  _buildActionButton(
                    icon: Icons.star_rounded,
                    color: const Color(0xFF2196F3),
                    onTap: () => _animateRemoval(true),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Divider
            Divider(
              color: AppTheme.borderColor(context),
              height: 1,
              thickness: 1,
            ),

            // Sección matches
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tus matches',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        Text(
                          '${_matches.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _matches.length,
                      itemBuilder: (context, index) =>
                          MatchItem(match: _matches[index]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 56,
    double iconSize = 28,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}