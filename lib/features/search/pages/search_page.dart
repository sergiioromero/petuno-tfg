import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../../features/profile/presentation/pages/user_profile_page.dart';
import '../widgets/search_filter_chips.dart';
import '../widgets/search_filters_bottom_sheet.dart';

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
  String _selectedPetType = 'Todos';
  Map<String, dynamic> _filters = {
    'distance': 10.0,
    'raza': 'Cualquiera',
    'color': 'Cualquiera',
    'ciudad': '',
  };
  Map<String, List<String>> _userPetTypes = {}; // uid -> tipos de mascota

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
            .where('name', isLessThan: '$q\uf8ff')
            .limit(50);
      } else {
        query = FirebaseFirestore.instance
            .collection('users')
            .limit(50);
      }

      final snapshot = await query.get();

      final users = <Map<String, dynamic>>[];
      final petTypes = <String, List<String>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final uid = data['uid'] ?? doc.id;
        
        // Fetch pet data for each user
        try {
          final petsSnap = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('pets')
              .get();
          final types = <String>[];
          for (final pet in petsSnap.docs) {
            final petData = pet.data();
            if (petData['type'] != null) {
              types.add(petData['type'].toString().toLowerCase());
            } else {
              // Inferir tipo del emoji
              final emoji = petData['emoji'] ?? '';
              if (emoji.contains('🐕') || emoji.contains('🐶')) {
                types.add('perro');
              } else if (emoji.contains('🐈') || emoji.contains('🐱')) {
                types.add('gato');
              } else if (emoji.contains('🦜') || emoji.contains('🐦')) {
                types.add('ave');
              } else if (emoji.contains('🐇') || emoji.contains('🐰')) {
                types.add('conejo');
              } else if (emoji.contains('🐠') || emoji.contains('🐟')) {
                types.add('pez');
              } else {
                types.add('otro');
              }
            }
          }
          petTypes[uid] = types;
        } catch (_) {
          petTypes[uid] = [];
        }

        users.add({
          'id': uid,
          'name': data['name'] ?? '',
          'age': data['age'] ?? 0,
          'location': data['location'] ?? '',
          'bio': data['bio'] ?? '',
          'avatarEmoji': data['avatarEmoji'] ?? '👤',
          'photoURL': data['photoURL'],
          'interests': List<String>.from(data['interests'] ?? []),
        });
      }

      setState(() {
        _results = users.where((u) => u['id'] != _currentUid).toList();
        _userPetTypes = petTypes;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredResults {
    var filtered = _results;
    
    // Filtro por texto
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((user) {
        return (user['name'] as String).toLowerCase().contains(q) ||
            (user['location'] as String).toLowerCase().contains(q);
      }).toList();
    }

    // Filtro por tipo de mascota
    if (_selectedPetType != 'Todos') {
      final typeMap = {
        'Perros': 'perro',
        'Gatos': 'gato',
        'Aves': 'ave',
        'Conejos': 'conejo',
        'Peces': 'pez',
        'Otros': 'otro',
      };
      final targetType = typeMap[_selectedPetType]?.toLowerCase();
      if (targetType != null) {
        filtered = filtered.where((user) {
          final types = _userPetTypes[user['id']] ?? [];
          return types.contains(targetType);
        }).toList();
      }
    }

    // Filtro por ciudad
    if (_filters['ciudad'] != null && (_filters['ciudad'] as String).isNotEmpty) {
      final city = (_filters['ciudad'] as String).toLowerCase();
      filtered = filtered.where((user) {
        return (user['location'] as String).toLowerCase().contains(city);
      }).toList();
    }

    return filtered;
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchFiltersBottomSheet(
        currentFilters: _filters,
        onApply: (filters) {
          setState(() => _filters = filters);
          if (_results.isEmpty) _fetchUsers();
        },
      ),
    );
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

            // Barra de búsqueda con filtro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
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
                          hintText: 'Nombre, ubicacion...',
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
                  const SizedBox(width: 8),
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderColor(context)),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.filter_list_rounded,
                          color: AppTheme.textSecondary(context)),
                      onPressed: () => _showFilters(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Filter chips
            SearchFilterChips(
              selected: _selectedPetType,
              onSelected: (type) {
                setState(() => _selectedPetType = type);
                if (_results.isEmpty) _fetchUsers();
              },
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