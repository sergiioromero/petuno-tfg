import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/theme/app_theme.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final notifRef = FirebaseFirestore.instance
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: notifRef.snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            final unread =
                docs.where((d) => d['isRead'] == false).toList();
            final read =
                docs.where((d) => d['isRead'] != false).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
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
                      if (unread.isNotEmpty)
                        GestureDetector(
                          onTap: () => _markAllAsRead(uid, unread),
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
                Expanded(
                  child: snapshot.connectionState ==
                          ConnectionState.waiting
                      ? Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryPink))
                      : docs.isEmpty
                          ? _buildEmpty(context)
                          : ListView(
                              children: [
                                if (unread.isNotEmpty) ...[
                                  _sectionHeader(
                                      context, 'Nuevas', unread.length),
                                  ...unread.map((d) => _NotifItem(
                                        doc: d,
                                        uid: uid,
                                      )),
                                  const SizedBox(height: 12),
                                ],
                                if (read.isNotEmpty) ...[
                                  _sectionHeader(
                                      context, 'Anteriores', null),
                                  ...read.map((d) => _NotifItem(
                                        doc: d,
                                        uid: uid,
                                      )),
                                ],
                                const SizedBox(height: 20),
                              ],
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _markAllAsRead(
      String uid, List<QueryDocumentSnapshot> unread) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in unread) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Widget _sectionHeader(
      BuildContext context, String label, int? count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(context),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppTheme.textSecondary(context).withOpacity(0.4),
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
    );
  }
}

// Widget de ítem

class _NotifItem extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final String uid;

  const _NotifItem({required this.doc, required this.uid});

  IconData _icon(String type) {
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

  Color _iconColor(String type) {
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

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final date = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return DateFormat('d MMM', 'es').format(date);
  }

  void _markRead() {
    if (doc['isRead'] == false) {
      doc.reference.update({'isRead': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final isUnread = data['isRead'] == false;
    final type = data['type'] ?? 'default';
    final fromName = data['fromName'] ?? 'Alguien';
    final message = data['message'] ?? '';
    final photoURL = data['fromPhotoURL'] as String?;
    final ts = data['createdAt'] as Timestamp?;

    final bgColors = {
      'match': const Color(0xFFFCE4EC),
      'like': const Color(0xFFFFEBEE),
      'message': const Color(0xFFE3F2FD),
      'comment': const Color(0xFFFFF8E1),
      'follower': const Color(0xFFF3E5F5),
    };
    final bgColor = bgColors[type] ?? const Color(0xFFF5F5F5);

    return GestureDetector(
      onTap: _markRead,
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
            // Avatar + badge
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: photoURL != null && photoURL.isNotEmpty
                        ? Image.network(photoURL, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                                child: Text('👤',
                                    style: TextStyle(fontSize: 22))))
                        : const Center(
                            child: Text('👤',
                                style: TextStyle(fontSize: 22))),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _iconColor(type),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.cardColor(context), width: 2),
                    ),
                    child: Icon(_icon(type), size: 11, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: fromName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        TextSpan(
                          text: ' $message',
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
                  Text(
                    _timeAgo(ts),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
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