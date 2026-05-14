import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../../../features/chat/presentation/pages/chat_list_page.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Icon(Icons.pets, color: AppTheme.primaryPink, size: 26),
          const SizedBox(width: 8),
          Text(
            'Petuno',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF111111),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => themeProvider.toggleTheme(),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              color: isDark ? Colors.amber : const Color(0xFF333333),
              size: 24,
            ),
          ),
        ),

        _MessageBadge(
          uid: uid,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<ChatBloc>(),
                  child: const ChatListPage(),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _MessageBadge extends StatelessWidget {
  final String uid;
  final bool isDark;
  final VoidCallback onTap;

  const _MessageBadge({
    required this.uid,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return IconButton(
        onPressed: onTap,
        icon: Icon(Icons.chat_bubble_outline,
            color: isDark ? Colors.white70 : const Color(0xFF333333)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participantIds', arrayContains: uid)
          .snapshots(),
      builder: (context, snapshot) {
        int totalUnread = 0;
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final unreadMap = data['unreadCount'] as Map<String, dynamic>?;
            if (unreadMap != null) {
              totalUnread += (unreadMap[uid] as num?)?.toInt() ?? 0;
            }
          }
        }

        return IconButton(
          onPressed: onTap,
          icon: totalUnread > 0
              ? Badge(
                  backgroundColor: AppTheme.primaryPink,
                  label: Text(
                    totalUnread > 99 ? '99+' : '$totalUnread',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: isDark ? Colors.white70 : const Color(0xFF333333),
                    size: 24,
                  ),
                )
              : Icon(
                  Icons.chat_bubble_outline,
                  color: isDark ? Colors.white70 : const Color(0xFF333333),
                  size: 24,
                ),
        );
      },
    );
  }
}
