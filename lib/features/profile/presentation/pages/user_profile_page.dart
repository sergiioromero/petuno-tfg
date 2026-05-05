import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../../../../features/chat/presentation/pages/chat_conversation_page.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _pets = [];
  bool _loading = true;
  bool _isFollowing = false;
  bool _followLoading = false;
  String _currentUid = '';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUid = authState.user.uid;
    }
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final targetRef = firestore.collection('users').doc(widget.userId);

      // Cargamos en paralelo: datos del usuario, si ya le seguimos,
      // y conteo real desde subcolecciones (nunca se desincroniza)
      final futures = await Future.wait([
        firestore
            .collection('users')
            .where('uid', isEqualTo: widget.userId)
            .limit(1)
            .get(),
        if (_currentUid.isNotEmpty)
          firestore
              .collection('users')
              .doc(_currentUid)
              .collection('following')
              .doc(widget.userId)
              .get(),
        targetRef.collection('followers').count().get(),
        targetRef.collection('following').count().get(),
      ]);

      final query = futures[0] as QuerySnapshot;
      if (query.docs.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      final userDoc = query.docs.first;
      bool alreadyFollowing = false;
      if (_currentUid.isNotEmpty) {
        final followDoc = futures[1] as DocumentSnapshot;
        alreadyFollowing = followDoc.exists;
      }

      final int offset = _currentUid.isNotEmpty ? 2 : 1;
      final followersSnap = futures[offset] as AggregateQuerySnapshot;
      final followingSnap = futures[offset + 1] as AggregateQuerySnapshot;

      final data = userDoc.data() as Map<String, dynamic>;
      data['followersCount'] = followersSnap.count ?? 0;
      data['followingCount'] = followingSnap.count ?? 0;

      setState(() {
        _userData = {'id': userDoc.id, ...data};
        _isFollowing = alreadyFollowing;
        _loading = false;
      });
    } catch (e) {
      print('Error cargando usuario: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_followLoading || _currentUid.isEmpty || _currentUid == widget.userId) return;
    setState(() => _followLoading = true);

    final firestore = FirebaseFirestore.instance;
    final myFollowingRef = firestore
        .collection('users')
        .doc(_currentUid)
        .collection('following')
        .doc(widget.userId);
    final theirFollowersRef = firestore
        .collection('users')
        .doc(widget.userId)
        .collection('followers')
        .doc(_currentUid);

    try {
      if (_isFollowing) {
        // Dejar de seguir: solo borramos los docs de subcolección
        await Future.wait([
          myFollowingRef.delete(),
          theirFollowersRef.delete(),
        ]);
        setState(() {
          _isFollowing = false;
          if (_userData != null) {
            final current = (_userData!['followersCount'] as int? ?? 1);
            _userData!['followersCount'] = current > 0 ? current - 1 : 0;
          }
        });
      } else {
        // Seguir: set con merge evita duplicados si el doc ya existía
        await Future.wait([
          myFollowingRef.set({
            'uid': widget.userId,
            'name': _userData?['name'] ?? '',
            'photoURL': _userData?['photoURL'],
            'avatarEmoji': _userData?['avatarEmoji'] ?? '👤',
            'followedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)),
          theirFollowersRef.set({
            'uid': _currentUid,
            'followedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)),
        ]);
        setState(() {
          _isFollowing = true;
          if (_userData != null) {
            _userData!['followersCount'] =
                (_userData!['followersCount'] as int? ?? 0) + 1;
          }
        });
      }

      if (context.mounted) {
        context.read<ProfileBloc>().add(LoadProfile(_currentUid));
      }
    } catch (_) {
      // Si falla, no cambiamos el estado
    }

    setState(() => _followLoading = false);
  }

  void _openChat() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final currentUid = authState.user.uid;
    final otherUid = widget.userId;
    final sorted = [currentUid, otherUid]..sort();
    final chatId = '${sorted[0]}_${sorted[1]}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChatBloc>(),
          child: ChatConversationPage(
            chatId: chatId,
            otherUserId: otherUid,
            otherUserName: _userData?['name'] ?? '',
            otherUserPhotoURL: _userData?['photoURL'],
            otherUserAvatarEmoji: _userData?['avatarEmoji'] ?? '👤',
            currentUid: currentUid,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary(context), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _userData?['name'] ?? '',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryPink))
          : _userData == null
              ? Center(
                  child: Text('Usuario no encontrado',
                      style: TextStyle(color: AppTheme.textSecondary(context))),
                )
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final interests = List<String>.from(_userData!['interests'] ?? []);
    final bio = _userData!['bio'] as String? ?? '';
    final location = _userData!['location'] as String? ?? '';
    final age = _userData!['age'] ?? 0;
    final followersCount = _userData!['followersCount'] ?? 0;
    final followingCount = _userData!['followingCount'] ?? 0;

    return ListView(
      children: [
        const SizedBox(height: 24),

        // Avatar
        Center(child: _buildAvatar()),

        const SizedBox(height: 16),

        // Nombre y edad
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _userData!['name'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary(context),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              if (age > 0)
                Text(
                  '$age',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Ubicación
        if (location.isNotEmpty)
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on,
                    size: 16, color: AppTheme.textSecondary(context)),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary(context)),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Seguidores / Siguiendo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(context, label: 'Seguidores', value: '$followersCount'),
              Container(
                width: 1,
                height: 32,
                color: AppTheme.borderColor(context),
              ),
              _buildStat(context, label: 'Siguiendo', value: '$followingCount'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Botones Follow + Mensaje
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Botón Follow
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _followLoading ? null : _toggleFollow,
                    icon: _followLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            _isFollowing
                                ? Icons.person_remove_outlined
                                : Icons.person_add_outlined,
                            size: 18,
                          ),
                    label: Text(
                      _isFollowing ? 'Siguiendo' : 'Seguir',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFollowing ? AppTheme.cardColor(context) : AppTheme.primaryPink,
                      foregroundColor:
                          _isFollowing ? AppTheme.primaryPink : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: _isFollowing
                            ? BorderSide(color: AppTheme.primaryPink)
                            : BorderSide.none,
                      ),
                      elevation: _isFollowing ? 0 : 3,
                      shadowColor: AppTheme.primaryPink.withOpacity(0.4),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Botón Mensaje
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _openChat,
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text(
                      'Mensaje',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cardColor(context),
                      foregroundColor: AppTheme.textPrimary(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: AppTheme.borderColor(context)),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Bio
        if (bio.isNotEmpty) ...[
          _buildSection(
            context,
            title: 'Bio',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                bio,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary(context),
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Intereses
        if (interests.isNotEmpty) ...[
          _buildSection(
            context,
            title: 'Intereses',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests
                    .map(
                      (interest) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.primaryPink.withOpacity(0.3)),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Mascotas
        _buildSection(
          context,
          title: 'Mascotas',
          child: _pets.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Este usuario aún no tiene mascotas',
                      style: TextStyle(
                          fontSize: 14, color: AppTheme.textSecondary(context)),
                    ),
                  ),
                )
              : SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _pets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) =>
                        _PetChip(pet: _pets[index]),
                  ),
                ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStat(BuildContext context,
      {required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final photoURL = _userData?['photoURL'] as String?;
    final avatarEmoji = _userData?['avatarEmoji'] ?? '👤';

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: photoURL == null
            ? LinearGradient(
                colors: [
                  AppTheme.primaryPink,
                  AppTheme.primaryPink.withOpacity(0.6),
                ],
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
        child: photoURL != null
            ? Image.network(
                photoURL,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                    child: Text(avatarEmoji,
                        style: const TextStyle(fontSize: 50))),
              )
            : Center(
                child: Text(avatarEmoji,
                    style: const TextStyle(fontSize: 50))),
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary(context),
            ),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _PetChip extends StatelessWidget {
  final Map<String, dynamic> pet;
  const _PetChip({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(pet['emoji'] ?? '🐾', style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            pet['name'] ?? '',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(context),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            pet['breed'] ?? pet['type'] ?? '',
            style: TextStyle(
                fontSize: 11, color: AppTheme.textSecondary(context)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}