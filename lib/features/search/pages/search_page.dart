import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../../features/profile/presentation/pages/user_profile_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];
  String _currentUid = '';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUid = authState.user.uid;
    }
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers({String? nameQuery}) async {
    setState(() => _loading = true);

    try {
      Query query;

      if (nameQuery != null && nameQuery.trim().isNotEmpty) {
        final q = nameQuery.trim();
        query = FirebaseFirestore.instance
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: q)
            .where('name', isLessThan: '${q}z')
            .limit(50);
      } else {
        query = FirebaseFirestore.instance
            .collection('users')
            .limit(50);
      }

      final snapshot = await query.get();

      final users = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'name': data['name'] ?? '',
              'age': data['age'] ?? 0,
              'location': data['location'] ?? '',
              'bio': data['bio'] ?? '',
              'avatarEmoji': data['avatarEmoji'] ?? '👤',
              'photoURL': data['photoURL'],
              'interests': List<String>.from(data['interests'] ?? []),
            };
          })
          .where((u) => u['id'] != _currentUid)
          .toList();

      setState(() {
        _results = users;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredResults {
    if (_searchQuery.isEmpty) return _results;
    return _results.where((user) {
      return (user['name'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (user['location'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredResults;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Buscar',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary(context),
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.borderColor(context)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) {
                    setState(() => _searchQuery = v);
                    if (v.length >= 2) {
                      _fetchUsers(nameQuery: v);
                    } else if (v.isEmpty) {
                      _fetchUsers();
                    }
                  },
                  style: TextStyle(color: AppTheme.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: 'Nombre, ubicación...',
                    hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary(context)),
                    prefixIcon: Icon(Icons.search,
                        color: AppTheme.textSecondary(context), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close,
                                size: 18,
                                color: AppTheme.textSecondary(context)),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                              _fetchUsers();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _loading
                    ? 'Buscando...'
                    : '${results.length} resultado${results.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary(context),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Lista de resultados
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryPink))
                  : results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 60,
                                  color: AppTheme.textSecondary(context)
                                      .withOpacity(0.3)),
                              const SizedBox(height: 12),
                              Text(
                                'Sin resultados',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: AppTheme.borderColor(context),
                          ),
                          itemBuilder: (context, index) {
                            final user = results[index];
                            return _UserListTile(
                              user: user,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserProfilePage(
                                      userId: user['id']),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  const _UserListTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final photoURL = user['photoURL'] as String?;
    final avatarEmoji = user['avatarEmoji'] ?? '👤';
    final interests = List<String>.from(user['interests'] ?? []);
    final age = user['age'] as int? ?? 0;
    final location = user['location'] as String? ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
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
              ),
              child: ClipOval(
                child: photoURL != null
                    ? Image.network(
                        photoURL,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                            child: Text(avatarEmoji,
                                style: const TextStyle(fontSize: 22))),
                      )
                    : Center(
                        child: Text(avatarEmoji,
                            style: const TextStyle(fontSize: 22))),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user['name'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      if (age > 0) ...[
                        const SizedBox(width: 5),
                        Text(
                          '$age',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (location.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 11,
                              color: AppTheme.textSecondary(context)),
                          const SizedBox(width: 2),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (interests.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        interests.take(3).join(' · '),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryPink.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary(context), size: 20),
          ],
        ),
      ),
    );
  }
}