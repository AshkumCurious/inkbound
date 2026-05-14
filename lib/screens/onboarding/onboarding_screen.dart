import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../themes/app_theme.dart';
import '../../themes/story_themes.dart';
import '../theme_select/theme_select_screen.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _total = 5;

  void _next() {
    if (_currentPage == _total - 1) {
      _leave();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _leave() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, anim, __) =>
            FadeTransition(opacity: anim, child: const ThemeSelectScreen()),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static const _accentColors = [
    Color(0xFF9B8FFF),
    Color(0xFF38BDF8),
    Color(0xFF4ADE80),
    Color(0xFFFBBF24),
    Color(0xFFA78BFA),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accentColors[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFF04040A),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (v) => setState(() => _currentPage = v),
            children: const [
              _PageWelcome(),
              _PageWorlds(),
              _PageChoices(),
              _PageWordTap(),
              _PageQuiz(),
            ],
          ),

          // Skip
          Positioned(
            top: 52,
            right: 24,
            child: GestureDetector(
              onTap: _leave,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomBar(
              current: _currentPage,
              total: _total,
              accent: accent,
              isLast: _currentPage == _total - 1,
              onNext: _next,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int current, total;
  final Color accent;
  final bool isLast;
  final VoidCallback onNext;

  const _BottomBar({
    required this.current,
    required this.total,
    required this.accent,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF04040A).withOpacity(0.98),
          ],
        ),
      ),
      child: Row(
        children: [
          Row(
            children: List.generate(total, (i) {
              final active = i == current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(right: 6),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: active ? accent : Colors.white.withOpacity(0.18),
                ),
              );
            }),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              padding: EdgeInsets.symmetric(
                horizontal: isLast ? 22 : 18,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: accent,
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLast)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Text(
                        'Begin',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.black87, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared shell — matches app header exactly ────────────────────────────────

class _Shell extends StatelessWidget {
  final Color accent;
  final String overline;
  final String title;
  final String subtitle;
  final Widget content;

  const _Shell({
    required this.accent,
    required this.overline,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF04040A), Color(0xFF0F172A), Color(0xFF140B1F)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overline — same as ThemeSelectScreen
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: accent),
                  ),
                  const SizedBox(width: 8),
                  Text(overline.toUpperCase(), style: AppTextStyles.overline()),
                ],
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.08, end: 0),

              const SizedBox(height: 16),

              // Title with same ShaderMask gradient as the app
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFD8B4FE), Color(0xFF93C5FD)],
                ).createShader(bounds),
                child: Text(
                  title,
                  style: AppTextStyles.displayLarge().copyWith(
                    height: 1.05,
                    letterSpacing: -1.5,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 600.ms)
                  .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),

              const SizedBox(height: 10),

              Text(
                subtitle,
                style: AppTextStyles.label(
                    color: Colors.white.withOpacity(0.35), size: 15),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 28),

              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Genre badge — same as ThemeCard ─────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          letterSpacing: 2.0,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE 1 — What is Inkbound
// ═══════════════════════════════════════════════════════════════════════════════

class _PageWelcome extends StatefulWidget {
  const _PageWelcome();

  @override
  State<_PageWelcome> createState() => _PageWelcomeState();
}

class _PageWelcomeState extends State<_PageWelcome>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF9B8FFF);
    const ink = Color(0xFF38BDF8); // "Ink" highlight colour
    const bound = Color(0xFFA78BFA); // "Bound" highlight colour

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF04040A), Color(0xFF0F172A), Color(0xFF140B1F)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 52, 26, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Eyebrow ────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: accent),
                  ),
                  const SizedBox(width: 8),
                  Text('WELCOME TO', style: AppTextStyles.overline()),
                ],
              ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.06, end: 0),

              const SizedBox(height: 28),

              // ── Brand wordmark — INK·BOUND split ──────────────────────
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // INK — cold, fluid
                    ShaderMask(
                      shaderCallback: (b) => LinearGradient(
                        colors: [
                          ink,
                          ink.withOpacity(0.6 + _pulse.value * 0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(b),
                      child: const Text(
                        'INK',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -3,
                          height: 1,
                        ),
                      ),
                    ),

                    // separator dot
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12, left: 3, right: 3),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),

                    // BOUND — warm, weighted
                    ShaderMask(
                      shaderCallback: (b) => LinearGradient(
                        colors: [
                          bound,
                          Colors.white.withOpacity(0.55 + _pulse.value * 0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(b),
                      child: const Text(
                        'BOUND',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -3,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 600.ms)
                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),

              const SizedBox(height: 6),

              // ── Name etymology line ────────────────────────────────────
              Row(
                children: [
                  _EtymPill(label: 'INK', sub: 'the story', color: ink),
                  const SizedBox(width: 8),
                  Text('×',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.2), fontSize: 13)),
                  const SizedBox(width: 8),
                  _EtymPill(label: 'BOUND', sub: 'your path', color: bound),
                ],
              ).animate().fadeIn(delay: 180.ms, duration: 400.ms),

              const SizedBox(height: 32),

              // ── Origin paragraph ───────────────────────────────────────
              _OriginCard(accent: accent)
                  .animate()
                  .fadeIn(delay: 260.ms, duration: 500.ms)
                  .slideY(begin: 0.05, end: 0, curve: Curves.easeOut),

              const SizedBox(height: 24),

              // ── Three value props ──────────────────────────────────────
              ...[
                (
                  Icons.auto_stories_rounded,
                  'AI-written stories, just for you',
                  'Every session generates a fresh narrative — no two reads are the same.',
                  accent,
                ),
                (
                  Icons.fork_right_rounded,
                  'Your choices bend the plot',
                  'Pick a path at every turn. Alternate outcomes are always one tap away.',
                  const Color(0xFF38BDF8),
                ),
                (
                  Icons.school_rounded,
                  'Learn as you go',
                  'Tap any word for an instant definition. Save new vocab without leaving the story.',
                  const Color(0xFF4ADE80),
                ),
              ].indexed.map((entry) {
                final i = entry.$1;
                final (icon, title, body, color) = entry.$2;
                return _ValueRow(
                  icon: icon,
                  title: title,
                  body: body,
                  color: color,
                )
                    .animate()
                    .fadeIn(
                        delay: Duration(milliseconds: 340 + i * 90),
                        duration: 420.ms)
                    .slideX(begin: -0.05, end: 0, curve: Curves.easeOut);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Etymology pill ─────────────────────────────────────────────────────────────

class _EtymPill extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;
  const _EtymPill(
      {required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.22), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 1.8,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Origin card ────────────────────────────────────────────────────────────────

class _OriginCard extends StatelessWidget {
  final Color accent;
  const _OriginCard({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0E0B1A),
        border: Border.all(color: accent.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote mark
          Text(
            '"',
            style: TextStyle(
              fontSize: 40,
              height: 0.6,
              color: accent.withOpacity(0.3),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'What if a story could change based on the reader — not just the writer?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Inkbound was born from that question. Traditional fiction locks you into one outcome. '
            'We built an AI that writes around your decisions in real time — so the story you read '
            'is the story only you could have created.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.45),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Value prop row ─────────────────────────────────────────────────────────────

class _ValueRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _ValueRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.10),
              border: Border.all(color: color.withOpacity(0.22), width: 1),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.4),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════════
// PAGE 2 — Worlds: real cards, tappable — matches ThemeCard layout exactly
// ═══════════════════════════════════════════════════════════════════════════════

class _PageWorlds extends StatefulWidget {
  const _PageWorlds();

  @override
  State<_PageWorlds> createState() => _PageWorldsState();
}

class _PageWorldsState extends State<_PageWorlds> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      accent: const Color(0xFF38BDF8),
      overline: 'Choose your world',
      title: '5 genres.\nInfinite\nstories.',
      subtitle: 'Tap one to preview it.',
      content: ListView(
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        children: storyThemes.asMap().entries.map((e) {
          final i = e.key;
          final t = e.value;
          final isSelected = _selected == i;

          return GestureDetector(
            onTap: () => setState(() => _selected = isSelected ? null : i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected ? t.surface : t.cardColor,
                border: Border.all(
                  color: isSelected
                      ? t.primary.withOpacity(0.5)
                      : t.primary.withOpacity(0.12),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: t.primary.withOpacity(isSelected ? 0.2 : 0.05),
                    blurRadius: isSelected ? 30 : 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar circle (placeholder for MiniCharacter)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.primary.withOpacity(0.15),
                      border: Border.all(
                          color: t.primary.withOpacity(0.3), width: 1.5),
                    ),
                    child:
                        Icon(Icons.person_rounded, color: t.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Badge(label: t.name, color: t.primary),
                        const SizedBox(height: 6),
                        Text(
                          t.tagline,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Text(
                            '"${t.starters.first}"',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: t.primary.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).animate().fadeIn(duration: 200.ms),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Arrow button — same as ThemeCard
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? t.primary : t.primary.withOpacity(0.1),
                      border: Border.all(color: t.primary.withOpacity(0.35)),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: isSelected ? Colors.white : t.primary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(
                  delay: Duration(milliseconds: 80 + i * 70), duration: 500.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE 3 — Choices: live interactive story demo
// ═══════════════════════════════════════════════════════════════════════════════

class _PageChoices extends StatefulWidget {
  const _PageChoices();

  @override
  State<_PageChoices> createState() => _PageChoicesState();
}

class _PageChoicesState extends State<_PageChoices> {
  int? _chosen;

  static const _story =
      'The vault door groans open. Inside: a single envelope with your name on it. '
      'The air smells of old paper and something electric.';

  static const _choices = [
    'Open the envelope immediately',
    'Check if anyone is watching first',
    'Leave — some things stay unknown.',
  ];

  static const _outcomes = [
    'Your hands tremble as it unfolds — coordinates, and a time: tonight.',
    'A shadow shifts behind the glass. You\'re not alone in here.',
    'Three steps out, your phone buzzes. A photo of you. Right now.',
  ];

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF4ADE80);
    const cardBg = Color(0xFF1F2A24);

    return _Shell(
      accent: accent,
      overline: 'Your choices matter',
      title: 'Every tap\nbends fate.',
      subtitle: 'Try making a choice below.',
      content: Column(
        children: [
          // Story card — same style as StorySegmentWidget
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, 0.05), end: Offset.zero)
                    .animate(anim),
                child: child,
              ),
            ),
            child: Container(
              key: ValueKey(_chosen),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withOpacity(0.12), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Text(
                _chosen != null ? _outcomes[_chosen!] : _story,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  color: Colors.white.withOpacity(0.85),
                  fontStyle:
                      _chosen != null ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_chosen == null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'WHAT HAPPENS NEXT?',
                style: AppTextStyles.overline(color: accent),
              ),
            ),
            ..._choices.asMap().entries.map((e) {
              return GestureDetector(
                onTap: () => setState(() => _chosen = e.key),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF16201A),
                    border:
                        Border.all(color: accent.withOpacity(0.22), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: accent.withOpacity(0.45), width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + e.key),
                            style: const TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.value,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8)),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(
                        delay: Duration(milliseconds: e.key * 80),
                        duration: 400.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
              );
            }),
          ] else ...[
            // Chosen indicator — same as StorySegmentWidget choiceMade row
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 14),
              child: Row(
                children: [
                  Icon(Icons.bookmark,
                      size: 16, color: accent.withOpacity(0.7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _choices[_chosen!],
                      style: TextStyle(
                          fontSize: 13, color: accent.withOpacity(0.75)),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
            GestureDetector(
              onTap: () => setState(() => _chosen = null),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: accent.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  'Try another path →',
                  style:
                      TextStyle(color: accent.withOpacity(0.75), fontSize: 13),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE 4 — Word tap
// ═══════════════════════════════════════════════════════════════════════════════

class _PageWordTap extends StatefulWidget {
  const _PageWordTap();

  @override
  State<_PageWordTap> createState() => _PageWordTapState();
}

class _PageWordTapState extends State<_PageWordTap> {
  String? _tapped;

  static const _defs = {
    'ephemeral': 'Lasting for a very short time; transitory.',
    'phosphorescent': 'Emitting light without heat; glowing softly.',
    'labyrinthine': 'Intricate and confusing, like a maze.',
    'vestige': 'A trace or remnant of something disappearing.',
  };

  static const _sentence =
      'The ephemeral glow of phosphorescent moss lined the labyrinthine corridor — '
      'the last vestige of a civilisation long forgotten.';

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFBBF24);
    const cardBg = Color(0xFF29251B);

    return _Shell(
      accent: accent,
      overline: 'Learn while you read',
      title: 'Tap any\nword.',
      subtitle: 'Definitions appear instantly. Save to your Vocab list.',
      content: Column(
        children: [
          // Story card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: cardBg,
              border: Border.all(color: accent.withOpacity(0.12), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Wrap(
              spacing: 3,
              runSpacing: 4,
              children: _sentence.split(' ').map((word) {
                final clean =
                    word.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
                final isKey = _defs.containsKey(clean);
                final isSelected = _tapped == clean;

                return GestureDetector(
                  onTap: isKey
                      ? () =>
                          setState(() => _tapped = isSelected ? null : clean)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isSelected
                          ? accent.withOpacity(0.18)
                          : Colors.transparent,
                      border: isKey && !isSelected
                          ? Border(
                              bottom: BorderSide(
                                color: accent.withOpacity(0.55),
                                width: 1.5,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      word,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: isSelected
                            ? accent
                            : isKey
                                ? Colors.white.withOpacity(0.95)
                                : Colors.white.withOpacity(0.65),
                        fontWeight: isKey ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

          const SizedBox(height: 8),
          Text(
            'Tap the underlined words above ↑',
            style: TextStyle(
              fontSize: 12,
              color: accent.withOpacity(0.4),
            ),
          ),

          const SizedBox(height: 16),

          // Definition popup card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, 0.08), end: Offset.zero)
                    .animate(anim),
                child: child,
              ),
            ),
            child: _tapped != null
                ? Container(
                    key: ValueKey(_tapped),
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: accent.withOpacity(0.07),
                      border:
                          Border.all(color: accent.withOpacity(0.22), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tapped!,
                          style: const TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _defs[_tapped]!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.bookmark_add_outlined,
                                size: 15, color: accent.withOpacity(0.55)),
                            const SizedBox(width: 6),
                            Text(
                              'Save to Vocab',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: accent.withOpacity(0.55)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE 5 — Quiz demo
// ═══════════════════════════════════════════════════════════════════════════════

class _PageQuiz extends StatefulWidget {
  const _PageQuiz();

  @override
  State<_PageQuiz> createState() => _PageQuizState();
}

class _PageQuizState extends State<_PageQuiz> {
  int? _selected;
  bool _submitted = false;

  static const _correct = 1;
  static const _q = 'What did the protagonist find inside the vault?';
  static const _opts = [
    'An ancient weapon',
    'An envelope with their name',
    'A map of the city',
    'Nothing — it was empty',
  ];

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFA78BFA);
    const cardBg = Color(0xFF1C1928);
    const surface = Color(0xFF13101C);

    return _Shell(
      accent: accent,
      overline: 'Comprehension quizzes',
      title: 'Stay sharp\nbetween\nchapters.',
      subtitle: 'A quick MCQ appears after every few scenes.',
      content: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: cardBg,
              border: Border.all(color: accent.withOpacity(0.12), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Badge(label: 'Q 1 of 3', color: accent),
                const SizedBox(height: 12),
                Text(
                  _q,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ..._opts.asMap().entries.map((e) {
                  final isSelected = _selected == e.key;
                  final isCorrect = e.key == _correct;

                  Color border = accent.withOpacity(0.15);
                  Color bg = surface;
                  Color text = Colors.white.withOpacity(0.7);

                  if (_submitted) {
                    if (isCorrect) {
                      border = const Color(0xFF4ADE80).withOpacity(0.5);
                      bg = const Color(0xFF4ADE80).withOpacity(0.08);
                      text = const Color(0xFF4ADE80);
                    } else if (isSelected) {
                      border = Colors.red.withOpacity(0.4);
                      bg = Colors.red.withOpacity(0.07);
                      text = Colors.red.shade300;
                    }
                  } else if (isSelected) {
                    border = accent.withOpacity(0.55);
                    bg = accent.withOpacity(0.1);
                    text = accent;
                  }

                  return GestureDetector(
                    onTap: _submitted
                        ? null
                        : () => setState(() => _selected = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: bg,
                        border: Border.all(color: border, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: text.withOpacity(0.6), width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + e.key),
                                style: TextStyle(
                                    color: text,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(e.value,
                                style: TextStyle(color: text, fontSize: 13)),
                          ),
                          if (_submitted && isCorrect)
                            const Icon(Icons.check_rounded,
                                color: Color(0xFF4ADE80), size: 15),
                          if (_submitted && isSelected && !isCorrect)
                            Icon(Icons.close_rounded,
                                color: Colors.red.shade300, size: 15),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
          const SizedBox(height: 12),
          if (!_submitted)
            GestureDetector(
              onTap: _selected == null
                  ? null
                  : () => setState(() => _submitted = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _selected != null ? accent : accent.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    'Submit Answer',
                    style: TextStyle(
                      color: _selected != null
                          ? Colors.black87
                          : Colors.white.withOpacity(0.3),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF4ADE80).withOpacity(0.08),
                border: Border.all(
                    color: const Color(0xFF4ADE80).withOpacity(0.28), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFF4ADE80), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _selected == _correct
                        ? 'Correct! Well remembered.'
                        : 'Not quite — re-read the story.',
                    style: const TextStyle(
                      color: Color(0xFF4ADE80),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut),
        ],
      ),
    );
  }
}
