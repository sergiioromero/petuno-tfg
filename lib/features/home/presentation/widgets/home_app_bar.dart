import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/providers/theme_provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Icon(Icons.pets, color: AppTheme.primaryPink, size: 26),
          const SizedBox(width: 8),
          Text(
            'Petuno',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF111111),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        // Botón cambio de tema
        IconButton(
          onPressed: () => themeProvider.toggleTheme(),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              color: isDark ? Colors.amber : const Color(0xFF333333),
              size: 24,
            ),
          ),
        ),
        
        IconButton(
          onPressed: () {
            // TODO: navegar a pantalla de mensajes
          },
          icon: Badge(
            backgroundColor: AppTheme.primaryPink,
            label: const Text('3',
                style: TextStyle(fontSize: 10, color: Colors.white)),
            child: Icon(
              Icons.chat_bubble_outline,
              color: isDark ? Colors.white70 : const Color(0xFF333333),
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}