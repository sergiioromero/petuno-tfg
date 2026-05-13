import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import 'welcome_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      icon: Icons.pets,
      title: 'Bienvenido a Petuno',
      desc: 'La comunidad donde dueños de mascotas\nconectan a traves de sus animales.',
      color: AppTheme.primaryPink,
    ),
    _OnboardingSlide(
      icon: Icons.favorite_rounded,
      title: 'Haz Matching',
      desc: 'Desliza hacia la derecha si te gusta\nun perfil. Si ambos se gustan,\n¡es un match!',
      color: const Color(0xFFE040FB),
    ),
    _OnboardingSlide(
      icon: Icons.chat_bubble_rounded,
      title: 'Chatea en Tiempo Real',
      desc: 'Cuando hagas match, podras chatear\ncon otros dueños y quedar\npara pasear juntos.',
      color: const Color(0xFF42A5F5),
    ),
    _OnboardingSlide(
      icon: Icons.explore_rounded,
      title: 'Explora y Descubre',
      desc: 'Busca personas cerca, filtra por tipo\nde mascota y encuentra el compañero\nperfecto para tu peludo.',
      color: const Color(0xFF66BB6A),
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Saltar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _buildSlide(_slides[i]),
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppTheme.primaryPink
                        : AppTheme.primaryPink.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Next / Start button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _slides.length - 1) {
                      _completeOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 3,
                    shadowColor: AppTheme.primaryPink.withOpacity(0.4),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1
                        ? 'Comenzar'
                        : 'Siguiente',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: slide.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 80, color: slide.color),
          ),
          const SizedBox(height: 40),
          Text(
            slide.title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: slide.color,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            slide.desc,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF777777),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });
}
