import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/story_theme.dart';
import 'mini_character.dart';

class ThemeCard extends StatefulWidget {
  final StoryTheme theme;
  final bool isHovered;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;
  final Duration delay;

  const ThemeCard({
    super.key,
    required this.theme,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
    required this.delay,
  });

  @override
  State<ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<ThemeCard>
    with SingleTickerProviderStateMixin {
  Offset _localCursor = Offset.zero;
  late AnimationController _particleController;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(() {
        if (mounted) setState(() => _updateParticles());
      });
  }

  @override
  void didUpdateWidget(ThemeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered && !oldWidget.isHovered) {
      _particleController.repeat();
    } else if (!widget.isHovered && oldWidget.isHovered) {
      _particleController.stop();
      _particles.clear();
    }
  }

  void _spawnParticle(Offset position) {
    final rand = math.Random();
    _particles.add(_Particle(
      position: position,
      velocity: Offset(
        (rand.nextDouble() - 0.5) * 80,
        -(rand.nextDouble() * 60 + 40),
      ),
      life: 1.0,
      size: rand.nextDouble() * 10 + 8,
      angle: rand.nextDouble() * math.pi * 2,
    ));
    if (_particles.length > 12) _particles.removeAt(0);
  }

  void _updateParticles() {
    const dt = 0.016;
    for (final p in _particles) {
      p.position += p.velocity * dt;
      p.velocity = Offset(p.velocity.dx * 0.97, p.velocity.dy + 30 * dt);
      p.life -= dt * 1.2;
      p.angle += dt * 2;
    }
    _particles.removeWhere((p) => p.life <= 0);
    if (widget.isHovered && math.Random().nextDouble() < 0.3) {
      _spawnParticle(_localCursor +
          Offset(
            (math.Random().nextDouble() - 0.5) * 20,
            (math.Random().nextDouble() - 0.5) * 20,
          ));
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      onHover: (event) {
        setState(() => _localCursor = event.localPosition);
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, widget.isHovered ? -10.0 : 0.0)
            ..scale(widget.isHovered ? 1.025 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: widget.isHovered ? theme.surface : theme.cardColor,
            border: Border.all(
              color: widget.isHovered
                  ? theme.primary.withOpacity(0.55)
                  : theme.primary.withOpacity(0.12),
              width: widget.isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    theme.primary.withOpacity(widget.isHovered ? 0.28 : 0.06),
                blurRadius: widget.isHovered ? 48 : 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // ── Background art: animated rings / lines ──
                Positioned.fill(
                    child: _CardBackgroundArt(
                        theme: theme, isHovered: widget.isHovered)),

                // ── Particle overlay ──
                if (widget.isHovered)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ParticlePainter(
                        particles: _particles,
                        color: theme.primary,
                        themeId: theme.id,
                      ),
                    ),
                  ),

                // ── Content ──
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Character
                      MiniCharacter(theme: theme),
                      const SizedBox(width: 20),

                      // Text block
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Genre badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: theme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                theme.name.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  letterSpacing: 2.0,
                                  color: theme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Tagline
                            Text(
                              theme.tagline,
                              style: TextStyle(
                                fontSize: 17,
                                height: 1.35,
                                color: Colors.white.withOpacity(0.88),
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // A starter prompt teaser
                            Text(
                              '"${theme.starters.first}"',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.white.withOpacity(0.38),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // CTA arrow
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isHovered
                              ? theme.primary
                              : theme.primary.withOpacity(0.12),
                          border: Border.all(
                            color: theme.primary.withOpacity(0.4),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color:
                              widget.isHovered ? Colors.white : theme.primary,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: widget.delay, duration: 600.ms)
        .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic);
  }
}

class _CardBackgroundArt extends StatelessWidget {
  final StoryTheme theme;
  final bool isHovered;

  const _CardBackgroundArt({required this.theme, required this.isHovered});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundArtPainter(
        primary: theme.primary,
        isHovered: isHovered,
        themeId: theme.id,
      ),
    );
  }
}

class _BackgroundArtPainter extends CustomPainter {
  final Color primary;
  final bool isHovered;
  final String themeId;

  const _BackgroundArtPainter({
    required this.primary,
    required this.isHovered,
    required this.themeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = isHovered ? 0.10 : 0.055;
    final paint = Paint()
      ..color = primary.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    switch (themeId) {
      case 'love':
        _drawHeartPattern(canvas, size, paint);
        break;
      case 'adventure':
        _drawDiagonalLines(canvas, size, paint);
        break;
      case 'creepy':
        _drawWebPattern(canvas, size, paint);
        break;
      case 'mystery':
        _drawGridDots(canvas, size, paint);
        break;
      case 'scifi':
        _drawCircuitLines(canvas, size, paint);
        break;
      default:
        _drawGridDots(canvas, size, paint);
    }

    // Right-side glow blob
    final blobPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primary.withOpacity(isHovered ? 0.18 : 0.08),
          primary.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.88, size.height * 0.5),
        radius: size.height * 0.8,
      ))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.5),
      size.height * 0.8,
      blobPaint,
    );
  }

  void _drawHeartPattern(Canvas canvas, Size size, Paint paint) {
    for (int i = 0; i < 3; i++) {
      final cx = size.width * 0.78 + i * 22.0;
      final cy = size.height * 0.25 + i * 18.0;
      _drawHeart(canvas, cx, cy, 12 + i * 4.0, paint);
    }
    _drawHeart(canvas, size.width * 0.92, size.height * 0.7, 18, paint);
  }

  void _drawHeart(Canvas canvas, double cx, double cy, double r, Paint p) {
    final path = Path();
    path.moveTo(cx, cy + r * 0.4);
    path.cubicTo(
        cx - r * 1.2, cy - r * 0.4, cx - r * 2, cy + r * 0.6, cx, cy + r * 1.8);
    path.cubicTo(
        cx + r * 2, cy + r * 0.6, cx + r * 1.2, cy - r * 0.4, cx, cy + r * 0.4);
    canvas.drawPath(path, p);
  }

  void _drawDiagonalLines(Canvas canvas, Size size, Paint paint) {
    const spacing = 22.0;
    for (double x = size.width * 0.5;
        x < size.width + size.height;
        x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        paint,
      );
    }
  }

  void _drawWebPattern(Canvas canvas, Size size, Paint paint) {
    final cx = size.width * 0.85;
    final cy = size.height * 0.3;
    for (int r = 1; r <= 3; r++) {
      canvas.drawCircle(Offset(cx, cy), r * 18.0, paint);
    }
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + math.cos(angle) * 54, cy + math.sin(angle) * 54),
        paint,
      );
    }
  }

  void _drawGridDots(Canvas canvas, Size size, Paint paint) {
    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    for (double x = size.width * 0.55; x < size.width; x += 18) {
      for (double y = 6; y < size.height; y += 18) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  void _drawCircuitLines(Canvas canvas, Size size, Paint paint) {
    final right = size.width;
    final h = size.height;
    // Horizontal trace
    canvas.drawLine(
        Offset(right * 0.6, h * 0.3), Offset(right * 0.95, h * 0.3), paint);
    // Vertical segment
    canvas.drawLine(
        Offset(right * 0.95, h * 0.3), Offset(right * 0.95, h * 0.65), paint);
    // Branch
    canvas.drawLine(
        Offset(right * 0.75, h * 0.3), Offset(right * 0.75, h * 0.55), paint);
    canvas.drawLine(
        Offset(right * 0.75, h * 0.55), Offset(right * 0.95, h * 0.55), paint);
    // Node dots
    final nodePaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    for (final pt in [
      Offset(right * 0.75, h * 0.3),
      Offset(right * 0.95, h * 0.3),
      Offset(right * 0.75, h * 0.55),
      Offset(right * 0.95, h * 0.65),
    ]) {
      canvas.drawCircle(pt, 3.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(_BackgroundArtPainter old) =>
      old.isHovered != isHovered || old.primary != primary;
}

class _Particle {
  Offset position;
  Offset velocity;
  double life; // 1.0 → 0.0
  double size;
  double angle;

  _Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.size,
    required this.angle,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final String themeId;

  const _ParticlePainter({
    required this.particles,
    required this.color,
    required this.themeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = color.withOpacity((p.life * 0.85).clamp(0, 1))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.angle);

      switch (themeId) {
        case 'love':
          _drawHeart(canvas, p.size * 0.5, paint);
          break;
        case 'adventure':
          _drawStar(canvas, p.size * 0.5, paint);
          break;
        case 'creepy':
          _drawGhost(canvas, p.size * 0.5, paint);
          break;
        case 'mystery':
          _drawDiamond(canvas, p.size * 0.5, paint);
          break;
        case 'scifi':
          _drawRocket(canvas, p.size * 0.5, paint);
          break;
        default:
          canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
      }

      canvas.restore();
    }
  }

  void _drawHeart(Canvas canvas, double r, Paint paint) {
    final path = Path();
    path.moveTo(0, r * 0.4);
    path.cubicTo(-r * 1.2, -r * 0.4, -r * 2, r * 0.6, 0, r * 1.8);
    path.cubicTo(r * 2, r * 0.6, r * 1.2, -r * 0.4, 0, r * 0.4);
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = Offset(
        r * math.cos((i * 4 * math.pi / 5) - math.pi / 2),
        r * math.sin((i * 4 * math.pi / 5) - math.pi / 2),
      );
      final inner = Offset(
        r * 0.4 * math.cos(((i * 4 + 2) * math.pi / 5) - math.pi / 2),
        r * 0.4 * math.sin(((i * 4 + 2) * math.pi / 5) - math.pi / 2),
      );
      if (i == 0)
        path.moveTo(outer.dx, outer.dy);
      else
        path.lineTo(outer.dx, outer.dy);
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawGhost(Canvas canvas, double r, Paint paint) {
    final path = Path();
    path.moveTo(-r, r);
    path.lineTo(-r, -r * 0.3);
    path.arcToPoint(Offset(r, -r * 0.3),
        radius: Radius.circular(r), clockwise: false);
    path.lineTo(r, r);
    // Wavy bottom
    path.quadraticBezierTo(r * 0.5, r * 0.6, 0, r);
    path.quadraticBezierTo(-r * 0.5, r * 0.6, -r, r);
    path.close();
    canvas.drawPath(path, paint);
    // Eyes
    final eyePaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-r * 0.35, -r * 0.1), r * 0.18, eyePaint);
    canvas.drawCircle(Offset(r * 0.35, -r * 0.1), r * 0.18, eyePaint);
  }

  void _drawDiamond(Canvas canvas, double r, Paint paint) {
    final path = Path()
      ..moveTo(0, -r)
      ..lineTo(r * 0.6, 0)
      ..lineTo(0, r)
      ..lineTo(-r * 0.6, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawRocket(Canvas canvas, double r, Paint paint) {
    // Body
    final body = Path()
      ..moveTo(0, -r)
      ..quadraticBezierTo(r * 0.6, -r * 0.3, r * 0.5, r * 0.5)
      ..lineTo(-r * 0.5, r * 0.5)
      ..quadraticBezierTo(-r * 0.6, -r * 0.3, 0, -r)
      ..close();
    canvas.drawPath(body, paint);
    // Fin left
    final finL = Path()
      ..moveTo(-r * 0.5, r * 0.2)
      ..lineTo(-r, r)
      ..lineTo(-r * 0.5, r * 0.5)
      ..close();
    canvas.drawPath(finL, paint);
    // Fin right
    final finR = Path()
      ..moveTo(r * 0.5, r * 0.2)
      ..lineTo(r, r)
      ..lineTo(r * 0.5, r * 0.5)
      ..close();
    canvas.drawPath(finR, paint);
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
