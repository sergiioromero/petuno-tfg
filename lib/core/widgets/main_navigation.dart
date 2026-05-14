import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petuno_app/features/matching/presentation/pages/matching_page.dart';
import 'package:petuno_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:petuno_app/features/profile/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/search/pages/search_page.dart';
import '../theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const MatchingPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: AppTheme.borderColor(context))),
          color: AppTheme.cardColor(context),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.cardColor(context),
          selectedItemColor: AppTheme.primaryPink,
          unselectedItemColor: AppTheme.textSecondary(context),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search_rounded),
              label: 'Buscar',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.pets_outlined),
              activeIcon: Icon(Icons.pets),
              label: 'Matching',
            ),
            BottomNavigationBarItem(
              icon: _NotifBadge(
                child: const Icon(Icons.notifications_outlined),
              ),
              activeIcon: _NotifBadge(
                child: const Icon(Icons.notifications_rounded),
              ),
              label: 'Alertas',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifBadge extends StatefulWidget {
  final Widget child;
  const _NotifBadge({required this.child});

  @override
  State<_NotifBadge> createState() => _NotifBadgeState();
}

class _NotifBadgeState extends State<_NotifBadge> {
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _stream = FirebaseFirestore.instance
          .collection('notifications')
          .doc(_uid)
          .collection('items')
          .where('isRead', isEqualTo: false)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null) return widget.child;

    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Badge(
          isLabelVisible: count > 0,
          label: Text(
            count > 99 ? '99+' : '$count',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          backgroundColor: Colors.red,
          textColor: Colors.white,
          smallSize: 8,
          child: widget.child,
        );
      },
    );
  }
}