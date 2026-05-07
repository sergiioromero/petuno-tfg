import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class StoriesRow extends StatelessWidget {
  const StoriesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryPink.withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPink.withOpacity(0.2),
                    AppTheme.primaryPink.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.primaryPink,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Historias',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Próximamente',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Comparte momentos de tu mascota con la comunidad',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary(context),
                      height: 1.3,
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
}