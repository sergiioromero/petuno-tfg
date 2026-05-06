import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SwipeCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const SwipeCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String? petPhotoURL = user['petPhotoURL'] as String?;
    final String? userPhotoURL = user['photoURL'] as String?;
    final String petEmoji = user['petEmoji'] ?? '🐾';
    final String avatarEmoji = user['avatarEmoji'] ?? '👤';
    final bgColor = Color(int.tryParse(
            (user['bgColor'] as String? ?? '0xFFFFF3E0')) ??
        0xFFFFF3E0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Foto de la mascota o emoji si no hay foto
            petPhotoURL != null
                ? Image.network(
                    petPhotoURL,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(petEmoji,
                          style: const TextStyle(fontSize: 140)),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(petEmoji,
                                style: const TextStyle(fontSize: 80)),
                            const SizedBox(height: 16),
                            CircularProgressIndicator(
                              color: AppTheme.primaryPink,
                              strokeWidth: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(petEmoji,
                        style: const TextStyle(fontSize: 140))),

            // Degradado
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.25, 0.65, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Info superior: foto del dueño
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Foto del dueño (real o emoji)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primaryPink.withOpacity(0.3),
                      backgroundImage: userPhotoURL != null
                          ? NetworkImage(userPhotoURL)
                          : null,
                      child: userPhotoURL == null
                          ? Text(avatarEmoji,
                              style: const TextStyle(fontSize: 24))
                          : null,
                    ),
                  ),

                  // Badge nombre mascota si hay
                  if ((user['petName'] as String? ?? '').isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(petEmoji,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 5),
                          Text(
                            user['petName'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Info inferior
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y edad
                  Row(
                    children: [
                      Text(
                        user['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if ((user['age'] ?? 0) > 0)
                        Text(
                          '${user['age']}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                    ],
                  ),

                  // Raza de la mascota
                  if ((user['petBreed'] as String? ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.pets,
                            size: 14, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 5),
                        Text(
                          user['petBreed'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Ubicación
                  if ((user['location'] as String? ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Text(
                          user['location'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Bio
                  if ((user['bio'] as String? ?? '').isNotEmpty)
                    Text(
                      user['bio'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Intereses
                  if ((user['interests'] as List?)?.isNotEmpty == true)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (user['interests'] as List<dynamic>)
                          .take(4)
                          .map(
                            (interest) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                interest.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                          .toList(),
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