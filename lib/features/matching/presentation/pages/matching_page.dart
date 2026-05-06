import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/pages/chat_conversation_page.dart';
import '../widgets/swipe_card.dart';
import '../widgets/match_item.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _candidates = [];
  List<Map<String, dynamic>> _matches = [];
  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0;
  bool _isDragging = false;
  bool _loading = true;
  String _currentUid = '';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUid = authState.user.uid;
    }
    _loadCandidates();
    _loadMatches();
  }

  Future<void> _loadCandidates() async {
    if (_currentUid.isEmpty) return;
    setState(() => _loading = true);

    try {
      // UIDs ya vistos
      final swipedSnap = await _db
          .collection('swipes')
          .doc(_currentUid)
          .collection('swiped')
          .get();
      final swipedUids = swipedSnap.docs.map((d) => d.id).toSet();
      swipedUids.add(_currentUid);

      final usersSnap = await _db.collection('users').limit(50).get();
      final candidates = <Map<String, dynamic>>[];

      for (final doc in usersSnap.docs) {
        if (swipedUids.contains(doc.id)) continue;
        final data = doc.data();
        final uid = doc.id;

        // Primera mascota del usuario
        final petsSnap = await _db
            .collection('users')
            .doc(uid)
            .collection('pets')
            .limit(1)
            .get();

        String petEmoji = '🐾';
        String petName = '';
        String petBreed = '';
        String? petPhotoURL;
        String bgColor = '0xFFFFF3E0';

        if (petsSnap.docs.isNotEmpty) {
          final p = petsSnap.docs.first.data();
          petEmoji = p['emoji'] ?? '🐾';
          petName = p['name'] ?? '';
          petBreed = p['breed'] ?? '';
          bgColor = p['bgColor'] ?? '0xFFFFF3E0';
          final photos = List<String>.from(p['photos'] ?? []);
          if (photos.isNotEmpty) petPhotoURL = photos.first;
        }

        candidates.add({
          'uid': uid,
          'name': data['name'] ?? '',
          'age': data['age'] ?? 0,
          'bio': data['bio'] ?? '',
          'location': data['location'] ?? '',
          'photoURL': data['photoURL'],
          'avatarEmoji': data['avatarEmoji'] ?? '👤',
          'interests': List<String>.from(data['interests'] ?? []),
          'petEmoji': petEmoji,
          'petName': petName,
          'petBreed': petBreed,
          'petPhotoURL': petPhotoURL,
          'bgColor': bgColor,
        });
      }

      if (mounted) {
        setState(() {
          _candidates = candidates;
          _currentIndex = 0;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMatches() async {
    if (_currentUid.isEmpty) return;
    try {
      final matchesSnap = await _db
          .collection('swipes')
          .doc(_currentUid)
          .collection('matches')
          .orderBy('matchedAt', descending: true)
          .get();

      final matches = <Map<String, dynamic>>[];
      for (final doc in matchesSnap.docs) {
        final data = doc.data();
        final otherUid = doc.id;

        final userDoc = await _db.collection('users').doc(otherUid).get();
        if (!userDoc.exists) continue;
        final userData = userDoc.data()!;

        final sorted = [_currentUid, otherUid]..sort();
        final chatId = '${sorted[0]}_${sorted[1]}';
        final chatDoc = await _db.collection('chats').doc(chatId).get();
        final lastMessage = chatDoc.exists
            ? (chatDoc.data()?['lastMessage'] ?? 'Toca para chatear')
            : 'Toca para chatear';

        matches.add({
          'uid': otherUid,
          'name': userData['name'] ?? data['name'] ?? '',
          'photoURL': userData['photoURL'],
          'avatarEmoji': userData['avatarEmoji'] ?? '👤',
          'petEmoji': data['petEmoji'] ?? '🐾',
          'lastMessage': lastMessage,
          'unread': 0,
        });
      }

      if (mounted) setState(() => _matches = matches);
    } catch (_) {}
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
      _animateRemoval(_dragOffset.dx > 0);
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _dragAngle = 0;
        _isDragging = false;
      });
    }
  }

  void _animateRemoval(bool isLike) {
    if (_candidates.isEmpty || _currentIndex >= _candidates.length) return;
    final candidate = _candidates[_currentIndex];

    setState(() {
      _dragOffset = Offset(isLike ? 500 : -500, _dragOffset.dy);
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _registerSwipe(candidate, isLike);
      setState(() {
        _currentIndex++;
        _dragOffset = Offset.zero;
        _dragAngle = 0;
        _isDragging = false;
      });
      if (_currentIndex >= _candidates.length) _loadCandidates();
    });
  }

  Future<void> _registerSwipe(
      Map<String, dynamic> candidate, bool isLike) async {
    if (_currentUid.isEmpty) return;
    final otherUid = candidate['uid'] as String;

    // Guardar como visto
    await _db
        .collection('swipes')
        .doc(_currentUid)
        .collection('swiped')
        .doc(otherUid)
        .set({
      'isLike': isLike,
      'swipedAt': FieldValue.serverTimestamp(),
    });

    if (!isLike) return;

    // Guardar like
    await _db
        .collection('swipes')
        .doc(_currentUid)
        .collection('likes')
        .doc(otherUid)
        .set({'likedAt': FieldValue.serverTimestamp()});

    // ¿Match mutuo?
    final theirLike = await _db
        .collection('swipes')
        .doc(otherUid)
        .collection('likes')
        .doc(_currentUid)
        .get();

    if (!theirLike.exists) return;

    // ¡Match! Guardar en ambos
    await Future.wait([
      _db
          .collection('swipes')
          .doc(_currentUid)
          .collection('matches')
          .doc(otherUid)
          .set({
        'matchedAt': FieldValue.serverTimestamp(),
        'name': candidate['name'],
        'photoURL': candidate['photoURL'],
        'petEmoji': candidate['petEmoji'] ?? '🐾',
      }),
      _db
          .collection('swipes')
          .doc(otherUid)
          .collection('matches')
          .doc(_currentUid)
          .set({
        'matchedAt': FieldValue.serverTimestamp(),
      }),
    ]);

    if (mounted) {
      _showMatchDialog(candidate);
      _loadMatches();
    }
  }

  void _showMatchDialog(Map<String, dynamic> candidate) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                '¡Es un match!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryPink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tú y ${candidate['name']} os habéis gustado mutuamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary(ctx),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: AppTheme.borderColor(ctx)),
                      ),
                      child: const Text('Seguir viendo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final sorted = [_currentUid, candidate['uid'] as String]
                          ..sort();
                        final chatId = '${sorted[0]}_${sorted[1]}';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ChatBloc>(),
                              child: ChatConversationPage(
                                chatId: chatId,
                                otherUserId: candidate['uid'],
                                otherUserName: candidate['name'],
                                otherUserPhotoURL: candidate['photoURL'],
                                otherUserAvatarEmoji:
                                    candidate['avatarEmoji'] ?? '👤',
                                currentUid: _currentUid,
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                        shadowColor: AppTheme.primaryPink.withOpacity(0.4),
                      ),
                      child: const Text('Chatear',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Descubre',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadCandidates,
                    icon: Icon(Icons.refresh_rounded,
                        color: AppTheme.textSecondary(context)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Swipe area
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryPink))
                    : _candidates.isEmpty ||
                            _currentIndex >= _candidates.length
                        ? _buildEmptyState(context)
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_currentIndex + 1 < _candidates.length)
                                Transform.scale(
                                  scale: 0.92,
                                  child: Opacity(
                                    opacity: 0.5,
                                    child: SwipeCard(
                                        user: _candidates[_currentIndex + 1]),
                                  ),
                                ),
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
                                      if (_isDragging && _dragOffset.dx < -40)
                                        _buildOverlay(context, false),
                                      if (_isDragging && _dragOffset.dx > 40)
                                        _buildOverlay(context, true),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),

            const SizedBox(height: 16),

            if (!_loading &&
                _candidates.isNotEmpty &&
                _currentIndex < _candidates.length)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBtn(Icons.close_rounded, Colors.redAccent,
                        () => _animateRemoval(false)),
                    _buildBtn(Icons.favorite_rounded, AppTheme.primaryPink,
                        () => _animateRemoval(true),
                        size: 70, iconSize: 36),
                    _buildBtn(Icons.star_rounded, const Color(0xFF2196F3),
                        () => _animateRemoval(true)),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            Divider(color: AppTheme.borderColor(context), height: 1),

            // Matches reales
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                    child: _matches.isEmpty
                        ? Center(
                            child: Text(
                              'Aún no tienes matches 💪',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                          )
                        : ListView.builder(
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🐾', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No hay más candidatos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vuelve más tarde o pulsa actualizar',
            style: TextStyle(
                fontSize: 14, color: AppTheme.textSecondary(context)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadCandidates,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, bool isLike) {
    final color = isLike ? AppTheme.primaryPink : Colors.redAccent;
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color, width: 5),
        ),
        child: Center(
          child: Transform.rotate(
            angle: isLike ? 0.3 : -0.3,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isLike ? 'LIKE' : 'NOPE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(IconData icon, Color color, VoidCallback onTap,
      {double size = 56, double iconSize = 28}) {
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
                offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}