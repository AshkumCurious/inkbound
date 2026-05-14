import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/story_theme.dart';
import '../../themes/app_theme.dart';
import '../../themes/story_themes.dart';
import '../../widgets/shared_widgets.dart';
import '../story/story_screen.dart';
import 'theme_card.dart';

class ThemeSelectScreen extends StatefulWidget {
  const ThemeSelectScreen({super.key});

  @override
  State<ThemeSelectScreen> createState() => _ThemeSelectScreenState();
}

class _ThemeSelectScreenState extends State<ThemeSelectScreen> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04040A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF04040A), Color(0xFF0F172A), Color(0xFF140B1F)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              left: -80,
              child: GlowOrb(color: Color(0x337C3AED), size: 280),
            ),
            const Positioned(
              bottom: -150,
              right: -100,
              child: GlowOrb(color: Color(0x222563EB), size: 340),
            ),
            Positioned.fill(
              child: CustomPaint(painter: _NoiseOverlayPainter()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildHeader(),
                  const SizedBox(height: 10),
                  Expanded(child: _buildThemeList()),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Overline label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI INTERACTIVE FICTION',
                style: AppTextStyles.overline(),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.1, end: 0, curve: Curves.easeOut),

          const SizedBox(height: 18),

          // Main heading — left-aligned, large editorial
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFD8B4FE), Color(0xFF93C5FD)],
            ).createShader(bounds),
            child: Text(
              'Choose Your World.',
              style: AppTextStyles.displayLarge().copyWith(
                height: 1.05,
                letterSpacing: -1.5,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 700.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Every decision rewrites the story.',
            style: AppTextStyles.label(
              color: Colors.white.withOpacity(0.35),
              size: 15,
            ),
          ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }

  Widget _buildThemeList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        clipBehavior: Clip.none, // ← stops side clipping
        padding: const EdgeInsets.only(
          top: 8, // ← gives the first card room to scale up
          bottom: 16,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: storyThemes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final theme = storyThemes[index];
          return ThemeCard(
            theme: theme,
            isHovered: _hoveredIndex == index,
            onHover: (v) => setState(() => _hoveredIndex = v ? index : null),
            onTap: () => _navigate(theme),
            delay: Duration(milliseconds: 80 + index * 70),
          );
        },
      ),
    );
  }

  void _navigate(StoryTheme theme) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: StoryScreen(theme: theme),
        ),
      ),
    );
  }
}

class _NoiseOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.012)
      ..style = PaintingStyle.fill;

    final rng = () => (size.width * 0.30).floor();
    const step = 4.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        // Deterministic pseudo-random using position
        final hash = ((x * 374761393 + y * 668265263).floor() % 100).abs();
        if (hash < 18) {
          canvas.drawCircle(Offset(x, y), 0.6, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_NoiseOverlayPainter old) => false;
}
