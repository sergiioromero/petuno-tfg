import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../widgets/notification_item.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'match',
      'name': 'Laura',
      'avatar': '👩',
      'bgColor': const Color(0xFFFCE4EC),
      'message': '¡Es un match! Empieza a chatear',
      'time': 'Hace 5 min',
      'unread': true,
    },
    {
      'type': 'like',
      'name': 'Carlos',
      'avatar': '👨',
      'bgColor': const Color(0xFFE8F5E9),
      'message': 'le dio like a tu publicación',
      'time': 'Hace 15 min',
      'unread': true,
    },
    {
      'type': 'message',
      'name': 'Miguel',
      'avatar': '🧑',
      'bgColor': const Color(0xFFE3F2FD),
      'message': 'te envió un mensaje',
      'time': 'Hace 1 hora',
      'unread': true,
    },
    {
      'type': 'comment',
      'name': 'Ana',
      'avatar': '👩',
      'bgColor': const Color(0xFFFFF8E1),
      'message': 'comentó: "Qué bonito tu perro! 😍"',
      'time': 'Hace 2 horas',
      'unread': false,
    },
    {
      'type': 'follower',
      'name': 'Pablo',
      'avatar': '👨',
      'bgColor': const Color(0xFFF3E5F5),
      'message': 'comenzó a seguirte',
      'time': 'Hace 3 horas',
      'unread': false,
    },
    {
      'type': 'like',
      'name': 'Sofía',
      'avatar': '🧑',
      'bgColor': const Color(0xFFFFF3E0),
      'message': 'le dio like a tu foto',
      'time': 'Ayer',
      'unread': false,
    },
    {
      'type': 'comment',
      'name': 'Elena',
      'avatar': '👩',
      'bgColor': const Color(0xFFE0F7FA),
      'message': 'comentó en tu publicación',
      'time': 'Ayer',
      'unread': false,
    },
    {
      'type': 'match',
      'name': 'Javier',
      'avatar': '👨',
      'bgColor': const Color(0xFFF1F8E9),
      'message': '¡Match! Dale me gusta y conecta',
      'time': 'Hace 2 días',
      'unread': false,
    },
  ];

  List<Map<String, dynamic>> get _unreadNotifications =>
      _notifications.where((n) => n['unread'] == true).toList();

  List<Map<String, dynamic>> get _readNotifications =>
      _notifications.where((n) => n['unread'] != true).toList();

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['unread'] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _unreadNotifications.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Cabecera
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notificaciones',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (hasUnread)
                    GestureDetector(
                      onTap: _markAllAsRead,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Marcar todo leído',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Lista de notificaciones
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 80,
                            color: AppTheme.textSecondary(context)
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sin notificaciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Te avisaremos cuando algo pase',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        // Sección: Nuevas
                        if (_unreadNotifications.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Text(
                                  'Nuevas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryPink,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_unreadNotifications.length}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ..._unreadNotifications
                              .map((n) => NotificationItem(notification: n)),
                          const SizedBox(height: 12),
                        ],

                        // Sección: Anteriores
                        if (_readNotifications.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              'Anteriores',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                          ),
                          ..._readNotifications
                              .map((n) => NotificationItem(notification: n)),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}