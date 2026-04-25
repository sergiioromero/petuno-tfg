import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class UserSuggestionsRow extends StatefulWidget {
  const UserSuggestionsRow({super.key});

  @override
  State<UserSuggestionsRow> createState() => _UserSuggestionsRowState();
}

class _UserSuggestionsRowState extends State<UserSuggestionsRow> {
  final List<Map<String, dynamic>> _suggestions = [
    {
      'name': 'Sofía',
      'pet': 'Golden Retriever',
      'emoji': '🐕',
      'bgColor': const Color(0xFFFFF3E0),
      'distance': '0.8 km',
    },
    {
      'name': 'Javier',
      'pet': 'Gato Persa',
      'emoji': '🐈',
      'bgColor': const Color(0xFFE8F5E9),
      'distance': '1.2 km',
    },
    {
      'name': 'Elena',
      'pet': 'Conejo enano',
      'emoji': '🐇',
      'bgColor': const Color(0xFFF3E5F5),
      'distance': '2.0 km',
    },
    {
      'name': 'Miguel',
      'pet': 'Loro',
      'emoji': '🦜',
      'bgColor': const Color(0xFFE3F2FD),
      'distance': '3.5 km',
    },
  ];

  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0;
  bool _isDragging = false;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragAngle = _dragOffset.dx * 0.001;
      _isDragging = true;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset.dx.abs() > 100) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
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
                onTap: () {
                  // TODO: navegar a pantalla de matching completa
                },
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

        // Stack de tarjetas centrado
        Center(
          child: SizedBox(
            height: 180,
            width: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Tarjeta fondo +2
                if (_suggestions.length > 2)
                  _buildCard(
                    _suggestions[(_currentIndex + 2) % _suggestions.length],
                    scale: 0.88,
                    yOffset: 16,
                    opacity: 0.5,
                  ),

                // Tarjeta fondo +1
                if (_suggestions.length > 1)
                  _buildCard(
                    _suggestions[(_currentIndex + 1) % _suggestions.length],
                    scale: 0.94,
                    yOffset: 8,
                    opacity: 0.75,
                  ),

                // Tarjeta principal con drag
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
                        _buildCard(
                          _suggestions[_currentIndex],
                          scale: 1.0,
                          yOffset: 0,
                          opacity: 1.0,
                        ),

                        // Icono X esquina superior izquierda
                        if (_isDragging && _dragOffset.dx < -30)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              opacity: ((-_dragOffset.dx - 30) / 70)
                                  .clamp(0.0, 1.0),
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
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),

                        // Icono corazón esquina superior derecha
                        if (_isDragging && _dragOffset.dx > 30)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              opacity: ((_dragOffset.dx - 30) / 70)
                                  .clamp(0.0, 1.0),
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
                                child: Icon(
                                  Icons.favorite_rounded,
                                  color: AppTheme.primaryPink,
                                  size: 22,
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

        const SizedBox(height: 12),

        // Indicador de puntos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _suggestions.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _currentIndex ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: i == _currentIndex
                    ? AppTheme.primaryPink
                    : const Color(0xFFDDDDDD),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    Map<String, dynamic> user, {
    required double scale,
    required double yOffset,
    required double opacity,
  }) {
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
              color: user['bgColor'],
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
                  // Emoji animal
                  Center(
                    child: Text(
                      user['emoji'],
                      style: const TextStyle(fontSize: 72),
                    ),
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
                        // Nombre y mascota
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              user['pet'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),

                        // Distancia
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 11, color: AppTheme.primaryPink),
                              const SizedBox(width: 3),
                              Text(
                                user['distance'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryPink,
                                ),
                              ),
                            ],
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