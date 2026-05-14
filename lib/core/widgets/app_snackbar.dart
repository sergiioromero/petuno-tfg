import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SnackBarType { success, error, info }

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
    Duration? duration,
  }) {
    Color bgColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        bgColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle_rounded;
        break;
      case SnackBarType.error:
        bgColor = const Color(0xFFE53935);
        icon = Icons.error_rounded;
        break;
      case SnackBarType.info:
        bgColor = AppTheme.primaryPink;
        icon = Icons.info_rounded;
        break;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          duration: duration ?? const Duration(seconds: 4),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
  }
}
