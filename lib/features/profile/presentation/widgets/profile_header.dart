import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user.dart';

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Foto de perfil — real si existe, emoji si no
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: user.photoURL == null
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryPink,
                      AppTheme.primaryPink.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: user.photoURL != null
                ? Image.network(
                    user.photoURL!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppTheme.primaryPink.withOpacity(0.2),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryPink,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Si falla la carga de la imagen, mostramos el emoji
                      return Container(
                        color: AppTheme.primaryPink.withOpacity(0.2),
                        child: Center(
                          child: Text(
                            user.avatarEmoji,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Text(
                        user.avatarEmoji,
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Nombre y edad
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary(context),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${user.age}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Ubicación
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: AppTheme.textSecondary(context),
            ),
            const SizedBox(width: 4),
            Text(
              user.location,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}