import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../widgets/search_filter_chips.dart';
import '../widgets/search_filters_bottom_sheet.dart';
import '../widgets/search_result_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {
    'distance': 10.0,
    'raza': 'Cualquiera',
    'color': 'Cualquiera',
    'ciudad': '',
  };

  // Datos de ejemplo — TODO: reemplazar con datos reales del backend
  static final List<Map<String, dynamic>> _allUsers = [
    {'name': 'Sofía', 'pet': 'Golden Retriever', 'emoji': '🐕',
      'bgColor': const Color(0xFFFFF3E0), 'distance': '0.8 km', 'type': 'Perros'},
    {'name': 'Carlos', 'pet': 'Gato Persa', 'emoji': '🐈',
      'bgColor': const Color(0xFFE8F5E9), 'distance': '1.2 km', 'type': 'Gatos'},
    {'name': 'Elena', 'pet': 'Conejo enano', 'emoji': '🐇',
      'bgColor': const Color(0xFFF3E5F5), 'distance': '2.0 km', 'type': 'Conejos'},
    {'name': 'Miguel', 'pet': 'Loro verde', 'emoji': '🦜',
      'bgColor': const Color(0xFFE3F2FD), 'distance': '3.5 km', 'type': 'Aves'},
    {'name': 'Laura', 'pet': 'Labrador', 'emoji': '🐕',
      'bgColor': const Color(0xFFFCE4EC), 'distance': '0.5 km', 'type': 'Perros'},
    {'name': 'Pablo', 'pet': 'Pez payaso', 'emoji': '🐠',
      'bgColor': const Color(0xFFE0F7FA), 'distance': '4.0 km', 'type': 'Peces'},
    {'name': 'Ana', 'pet': 'Bulldog francés', 'emoji': '🐕',
      'bgColor': const Color(0xFFFFF8E1), 'distance': '1.8 km', 'type': 'Perros'},
    {'name': 'Marcos', 'pet': 'Siamés', 'emoji': '🐈',
      'bgColor': const Color(0xFFF1F8E9), 'distance': '2.5 km', 'type': 'Gatos'},
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    return _allUsers.where((user) {
      final matchesCategory = _selectedCategory == 'Todos' ||
          user['type'] == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['pet'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  int get _activeFilterCount {
    int count = 0;
    if (_activeFilters['distance'] != 10.0) count++;
    if (_activeFilters['raza'] != 'Cualquiera') count++;
    if (_activeFilters['color'] != 'Cualquiera') count++;
    if ((_activeFilters['ciudad'] as String).isNotEmpty) count++;
    return count;
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SearchFiltersBottomSheet(
          currentFilters: _activeFilters,
          onApply: (filters) => setState(() => _activeFilters = filters),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredUsers;

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

            // Barra de búsqueda + botón filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Nombre, raza, animal...',
                          hintStyle: TextStyle(
                              fontSize: 14, color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFFBBBBBB), size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      size: 18, color: Color(0xFFBBBBBB)),
                                  onPressed: () => setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  }),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Botón filtros con badge
                  GestureDetector(
                    onTap: _openFilters,
                    child: Stack(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _activeFilterCount > 0
                                ? AppTheme.primaryPink
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _activeFilterCount > 0
                                  ? AppTheme.primaryPink
                                  : const Color(0xFFEEEEEE),
                            ),
                            boxShadow: _activeFilterCount > 0
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryPink
                                          .withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: _activeFilterCount > 0
                                ? Colors.white
                                : const Color(0xFF555555),
                            size: 22,
                          ),
                        ),
                        if (_activeFilterCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$_activeFilterCount',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryPink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Chips de categoría
            SearchFilterChips(
              selected: _selectedCategory,
              onSelected: (cat) =>
                  setState(() => _selectedCategory = cat),
            ),

            const SizedBox(height: 16),

            // Contador de resultados
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${results.length} resultado${results.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888888),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Grid de resultados
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 60,
                              color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            'Sin resultados',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: results.length,
                      itemBuilder: (context, index) =>
                          SearchResultCard(user: results[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}