import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class StoriesRow extends StatelessWidget {
  const StoriesRow({super.key});

  static const List<Map<String, dynamic>> _stories = [
    {'name': 'Tú', 'emoji': '➕', 'isOwn': true},
    {'name': 'Carlos', 'emoji': '🐕', 'isOwn': false},
    {'name': 'Laura', 'emoji': '🐈', 'isOwn': false},
    {'name': 'Marta', 'emoji': '🐇', 'isOwn': false},
    {'name': 'Pedro', 'emoji': '🦜', 'isOwn': false},
    {'name': 'Ana', 'emoji': '🐠', 'isOwn': false},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final story = _stories[index];
          return GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: story['isOwn']
                        ? null
                        : LinearGradient(
                            colors: [
                              AppTheme.primaryPink,
                              const Color(0xFFFF5BB5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: story['isOwn'] ? AppTheme.inputBackground(context) : null,
                    border: story['isOwn']
                        ? Border.all(
                            color: AppTheme.borderColor(context),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      story['emoji'],
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  story['name'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}