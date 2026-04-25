import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class SearchFilterChips extends StatelessWidget {
  final String selected;
  final Function(String) onSelected;

  const SearchFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const List<Map<String, String>> categories = [
    {'label': 'Todos', 'emoji': '🐾'},
    {'label': 'Perros', 'emoji': '🐕'},
    {'label': 'Gatos', 'emoji': '🐈'},
    {'label': 'Aves', 'emoji': '🦜'},
    {'label': 'Conejos', 'emoji': '🐇'},
    {'label': 'Peces', 'emoji': '🐠'},
    {'label': 'Otros', 'emoji': '🦎'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selected == cat['label'];
          return GestureDetector(
            onTap: () => onSelected(cat['label']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryPink : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryPink
                      : const Color(0xFFEEEEEE),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryPink.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Text(cat['emoji']!,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(
                    cat['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}