import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../../../../features/chat/presentation/pages/chat_conversation_page.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (!userDoc.exists) {
        setState(() => _loading = false);
        return;
      }

      final petsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('pets')
          .get();

      setState(() {
        _userData = {'id': userDoc.id, ...userDoc.data()!};
        _pets = petsSnapshot.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
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
          ? Center(
              child:
                  CircularProgressIndicator(color: AppTheme.primaryPink))
          : _userData == null
              ? Center(
                  child: Text(
                    'Usuario no encontrado',
                    style:
                        TextStyle(color: AppTheme.textSecondary(context)),
                  ),
                )
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final interests =
        List<String>.from(_userData!['interests'] ?? []);
    final bio = _userData!['bio'] as String? ?? '';
    final location = _userData!['location'] as String? ?? '';
    final age = _userData!['age'] ?? 0;

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
                    size: 16,
                    color: AppTheme.textSecondary(context)),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Botón enviar mensaje
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _openChat,
              icon: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 20),
              label: const Text(
                'Enviar mensaje',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 3,
                shadowColor: AppTheme.primaryPink.withOpacity(0.4),
              ),
            ),
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
                          color:
                              AppTheme.primaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryPink
                                .withOpacity(0.3),
                          ),
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
                        fontSize: 14,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    itemCount: _pets.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) =>
                        _PetChip(pet: _pets[index]),
                  ),
                ),
        ),

        const SizedBox(height: 32),
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
          Text(
            pet['emoji'] ?? '🐾',
            style: const TextStyle(fontSize: 36),
          ),
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
              fontSize: 11,
              color: AppTheme.textSecondary(context),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}