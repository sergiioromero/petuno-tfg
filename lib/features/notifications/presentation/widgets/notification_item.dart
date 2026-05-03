import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationItem({super.key, required this.notification});

  IconData _getIcon(String type) {
    switch (type) {
      case 'match':
        return Icons.favorite_rounded;
      case 'like':
        return Icons.favorite_border_rounded;
      case 'message':
        return Icons.chat_bubble_rounded;
      case 'comment':
        return Icons.comment_rounded;
      case 'follower':
        return Icons.person_add_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'match':
        return AppTheme.primaryPink;
      case 'like':
        return Colors.redAccent;
      case 'message':
        return const Color(0xFF2196F3);
      case 'comment':
        return const Color(0xFFFF9800);
      case 'follower':
        return const Color(0xFF9C27B0);
      default:
        return AppTheme.primaryPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = notification['unread'] ?? false;

    return GestureDetector(
      onTap: () {
        // TODO: navegar a la acción correspondiente
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? AppTheme.primaryPink.withOpacity(0.05)
              : AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppTheme.primaryPink.withOpacity(0.2)
                : AppTheme.borderColor(context),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar con badge de tipo
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: notification['bgColor'],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      notification['avatar'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getIconColor(notification['type']),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.cardColor(context),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getIcon(notification['type']),
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensaje
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: notification['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        TextSpan(
                          text: ' ${notification['message']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Tiempo
                  Text(
                    notification['time'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Indicador no leída
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}