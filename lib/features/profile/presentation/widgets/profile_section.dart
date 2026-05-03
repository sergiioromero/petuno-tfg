import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final Widget child;

  const ProfileSection({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
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