import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class SearchFiltersBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApply;

  const SearchFiltersBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<SearchFiltersBottomSheet> createState() =>
      _SearchFiltersBottomSheetState();
}

class _SearchFiltersBottomSheetState extends State<SearchFiltersBottomSheet> {
  late double _distance;
  late String _raza;
  late String _color;
  late String _ciudad;

  static const List<String> _razas = [
    'Cualquiera', 'Golden Retriever', 'Bulldog', 'Labrador',
    'Pastor Alemán', 'Persa', 'Siamés', 'Maine Coon',
  ];

  static const List<String> _colores = [
    'Cualquiera', 'Marrón', 'Negro', 'Blanco',
    'Naranja', 'Gris', 'Multicolor',
  ];

  @override
  void initState() {
    super.initState();
    _distance = widget.currentFilters['distance'] ?? 10.0;
    _raza = widget.currentFilters['raza'] ?? 'Cualquiera';
    _color = widget.currentFilters['color'] ?? 'Cualquiera';
    _ciudad = widget.currentFilters['ciudad'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Título
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _distance = 10.0;
                    _raza = 'Cualquiera';
                    _color = 'Cualquiera';
                    _ciudad = '';
                  });
                },
                child: Text(
                  'Resetear',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Distancia
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Distancia máxima',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_distance.round()} km',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _distance,
            min: 1,
            max: 100,
            divisions: 99,
            activeColor: AppTheme.primaryPink,
            inactiveColor: AppTheme.primaryPink.withOpacity(0.15),
            onChanged: (v) => setState(() => _distance = v),
          ),

          const SizedBox(height: 8),

          // Raza
          _buildDropdown('Raza', _razas, _raza,
              (v) => setState(() => _raza = v!)),

          const SizedBox(height: 16),

          // Color
          _buildDropdown('Color', _colores, _color,
              (v) => setState(() => _color = v!)),

          const SizedBox(height: 16),

          // Ciudad
          const Text(
            'Ciudad',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _ciudad,
            onChanged: (v) => _ciudad = v,
            decoration: InputDecoration(
              hintText: 'Ej: Madrid',
              hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
              prefixIcon: Icon(Icons.location_city_outlined,
                  color: AppTheme.primaryPink, size: 20),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: AppTheme.primaryPink, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Botón aplicar
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply({
                  'distance': _distance,
                  'raza': _raza,
                  'color': _color,
                  'ciudad': _ciudad,
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                shadowColor: AppTheme.primaryPink.withOpacity(0.4),
              ),
              child: const Text(
                'Aplicar filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String value,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppTheme.primaryPink, width: 1.5),
            ),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ],
    );
  }
}