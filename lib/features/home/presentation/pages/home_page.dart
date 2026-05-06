import 'package:flutter/material.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/stories_row.dart';
import '../widgets/user_suggestions_row.dart';
import '../widgets/post_card.dart';
import '../../../../../../core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final List<Map<String, dynamic>> _posts = [
    {
      'user': 'Sofía',
      'avatar': '👩',
      'time': 'hace 5 min',
      'petEmoji': '🐕',
      'petName': 'Luna · Golden Retriever',
      'bgColor': const Color(0xFFFFF3E0),
      'description': 'Mi perrita Luna en su paseo matutino 🌸',
      'tags': ['perros', 'goldenretriever', 'paseo'],
      'match': 92,
      'likes': 24,
      'comments': 5,
    },
    {
      'user': 'Carlos',
      'avatar': '👨',
      'time': 'hace 20 min',
      'petEmoji': '🐈',
      'petName': 'Michi · Gato Persa',
      'bgColor': const Color(0xFFE8F5E9),
      'description': 'Michi encontró su rincón favorito del sofá 😂',
      'tags': ['gatos', 'gatopersa', 'felinos'],
      'match': 87,
      'likes': 41,
      'comments': 8,
    },
    {
      'user': 'Elena',
      'avatar': '🧑',
      'time': 'hace 1 h',
      'petEmoji': '🐇',
      'petName': 'Nieve · Conejo enano',
      'bgColor': const Color(0xFFF3E5F5),
      'description': 'Primer día de Nieve en el jardín 🌿',
      'tags': ['conejos', 'conejosenano', 'mascota'],
      'match': 76,
      'likes': 18,
      'comments': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: const HomeAppBar(),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SearchBarWidget(),
          ),

          const SizedBox(height: 20),

          const StoriesRow(),

          const SizedBox(height: 20),

          const UserSuggestionsRow(),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Publicaciones recientes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ),

          const SizedBox(height: 8),

          ..._posts.map((post) => PostCard(post: post)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}