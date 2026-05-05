import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../search/pages/search_page.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.inputBackground(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.borderColor(context)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search, color: AppTheme.textSecondary(context), size: 20),
            const SizedBox(width: 10),
            Text(
              'Buscar mascotas o personas...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}