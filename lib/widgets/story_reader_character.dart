import 'package:flutter/material.dart';
import '../models/story_theme.dart';

class StoryReaderCharacter extends StatefulWidget {
  final StoryTheme theme;
  final bool isReading;
  final bool isLoading;

  const StoryReaderCharacter({
    super.key,
    required this.theme,
    this.isReading = false,
    this.isLoading = false,
  });

  @override
  State<StoryReaderCharacter> createState() => _StoryReaderCharacterState();
}

class _StoryReaderCharacterState extends State<StoryReaderCharacter>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _blinkController;
  late AnimationController _pageController;
  late Animation<double> _breathAnim;
  late Animation<double> _blinkAnim;
  late Animation<double> _pageAnim;

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _breathAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _blinkAnim = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _pageAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
    );

    _startBlinkCycle();
  }

  void _startBlinkCycle() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 3500));
      if (!mounted) break;
      await _blinkController.forward();
      await _blinkController.reverse();
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) break;
      await _blinkController.forward();
      await _blinkController.reverse();
    }
  }

  @override
  void didUpdateWidget(StoryReaderCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _pageController.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _pageController.stop();
      _pageController.reset();
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _blinkController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathAnim, _blinkAnim, _pageAnim]),
      builder: (context, _) {
        return CustomPaint(
          painter: _CharacterPainter(
            theme: widget.theme,
            breathValue: _breathAnim.value,
            blinkValue: _blinkAnim.value,
            pageValue: _pageAnim.value,
            isReading: widget.isReading,
            mood: widget.theme.characterMood,
          ),
          size: const Size(180, 220),
        );
      },
    );
  }
}

class _CharacterPainter extends CustomPainter {
  final StoryTheme theme;
  final double breathValue;
  final double blinkValue;
  final double pageValue;
  final bool isReading;
  final CharacterMood mood;

  _CharacterPainter({
    required this.theme,
    required this.breathValue,
    required this.blinkValue,
    required this.pageValue,
    required this.isReading,
    required this.mood,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final breathOffset = breathValue * 2.5;

    _drawBody(canvas, size, cx, breathOffset);
    _drawBook(canvas, size, cx, breathOffset);
    _drawHead(canvas, cx, breathOffset);
    _drawHair(canvas, cx, breathOffset);
    _drawFace(canvas, cx, breathOffset);
    _drawAccessory(canvas, cx, breathOffset);
    _drawAura(canvas, size, cx);
  }

  void _drawAura(Canvas canvas, Size size, double cx) {
    final paint = Paint()
      ..color = theme.primary.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(
      Offset(cx, size.height - 30),
      55,
      paint,
    );
  }

  void _drawBody(Canvas canvas, Size size, double cx, double breathOffset) {
    final bodyPaint = Paint()..color = theme.characterClothingColor;
    final shoulderY = 128.0 + breathOffset * 0.3;

    // Torso
    final bodyPath = Path()
      ..moveTo(cx - 34, shoulderY)
      ..cubicTo(cx - 38, shoulderY + 10, cx - 40, shoulderY + 30, cx - 36,
          shoulderY + 60)
      ..lineTo(cx + 36, shoulderY + 60)
      ..cubicTo(
          cx + 40, shoulderY + 30, cx + 38, shoulderY + 10, cx + 34, shoulderY)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Collar detail
    final collarPaint = Paint()
      ..color = theme.characterAccentColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(cx - 10, shoulderY + 2),
      Offset(cx, shoulderY + 12),
      collarPaint,
    );
    canvas.drawLine(
      Offset(cx + 10, shoulderY + 2),
      Offset(cx, shoulderY + 12),
      collarPaint,
    );

    // Arms
    _drawArms(canvas, cx, shoulderY, breathOffset);
  }

  void _drawArms(
      Canvas canvas, double cx, double shoulderY, double breathOffset) {
    final armPaint = Paint()..color = theme.characterSkinTone;
    final clothingPaint = Paint()..color = theme.characterClothingColor;

    // Left arm (holding book bottom)
    final leftArmPath = Path()
      ..moveTo(cx - 34, shoulderY + 5)
      ..cubicTo(cx - 52, shoulderY + 15, cx - 58, shoulderY + 40, cx - 48,
          shoulderY + 60)
      ..lineTo(cx - 40, shoulderY + 58)
      ..cubicTo(cx - 50, shoulderY + 38, cx - 44, shoulderY + 16, cx - 28,
          shoulderY + 8)
      ..close();
    canvas.drawPath(leftArmPath, clothingPaint);

    // Left hand
    final leftHandPaint = Paint()..color = theme.characterSkinTone;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 46, shoulderY + 63),
        width: 14,
        height: 10,
      ),
      leftHandPaint,
    );

    // Right arm
    final rightArmPath = Path()
      ..moveTo(cx + 34, shoulderY + 5)
      ..cubicTo(cx + 52, shoulderY + 15, cx + 56, shoulderY + 38, cx + 46,
          shoulderY + 56)
      ..lineTo(cx + 38, shoulderY + 54)
      ..cubicTo(cx + 48, shoulderY + 36, cx + 44, shoulderY + 14, cx + 28,
          shoulderY + 8)
      ..close();
    canvas.drawPath(rightArmPath, clothingPaint);

    // Right hand
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 44, shoulderY + 59),
        width: 14,
        height: 10,
      ),
      armPaint,
    );
  }

  void _drawBook(Canvas canvas, Size size, double cx, double breathOffset) {
    final bookY = 148.0 + breathOffset * 0.5;
    final pageFlip = pageValue * 6;

    // Book shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, bookY + 22), width: 68, height: 12),
      shadowPaint,
    );

    // Book cover left page
    final leftPage = Paint()..color = const Color(0xFFF5EFE0);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - 36, bookY, 36, 28),
        topLeft: const Radius.circular(3),
        bottomLeft: const Radius.circular(3),
      ),
      leftPage,
    );

    // Book lines left page
    final linePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(cx - 30, bookY + 6 + i * 5.0),
        Offset(cx - 6, bookY + 6 + i * 5.0),
        linePaint,
      );
    }

    // Book cover right page
    final rightPage = Paint()..color = const Color(0xFFEDE8D8);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(cx, bookY, 36, 28),
        topRight: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      rightPage,
    );

    // Animated page lines on right (shifts when loading)
    final animLinePaint = Paint()
      ..color = theme.primary.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final xEnd = (cx + 6 + (i == 1 ? pageFlip : 0));
      canvas.drawLine(
        Offset(cx + 6, bookY + 6 + i * 5.0),
        Offset(xEnd + 24, bookY + 6 + i * 5.0),
        animLinePaint,
      );
    }

    // Spine
    final spinePaint = Paint()..color = theme.primary.withValues(alpha: 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 3, bookY - 1, 6, 30),
        const Radius.circular(2),
      ),
      spinePaint,
    );

    // Bookmark ribbon
    if (mood != CharacterMood.scared) {
      final ribbonPaint = Paint()..color = theme.primary.withValues(alpha: 0.9);
      final ribbonPath = Path()
        ..moveTo(cx + 22, bookY)
        ..lineTo(cx + 26, bookY)
        ..lineTo(cx + 26, bookY + 14)
        ..lineTo(cx + 24, bookY + 11)
        ..lineTo(cx + 22, bookY + 14)
        ..close();
      canvas.drawPath(ribbonPath, ribbonPaint);
    }
  }

  void _drawHead(Canvas canvas, double cx, double breathOffset) {
    final headY = 60.0 - breathOffset * 0.5;
    final headPaint = Paint()..color = theme.characterSkinTone;

    // Neck
    final neckPaint = Paint()..color = theme.characterSkinTone;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, headY + 52), width: 18, height: 22),
        const Radius.circular(4),
      ),
      neckPaint,
    );

    // Head
    final headPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx, headY + 30),
        width: 62,
        height: 70,
      ));
    canvas.drawPath(headPath, headPaint);

    // Ear left
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - 31, headY + 30), width: 10, height: 14),
      headPaint,
    );
    // Ear right
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx + 31, headY + 30), width: 10, height: 14),
      headPaint,
    );

    // Cheeks (blush) for dreamy/curious
    if (mood == CharacterMood.dreamy || mood == CharacterMood.curious) {
      final blushPaint = Paint()..color = theme.primary.withValues(alpha: 0.2);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx - 20, headY + 38), width: 16, height: 8),
        blushPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + 20, headY + 38), width: 16, height: 8),
        blushPaint,
      );
    }
  }

  void _drawHair(Canvas canvas, double cx, double breathOffset) {
    final headY = 60.0 - breathOffset * 0.5;
    final hairPaint = Paint()..color = theme.characterHairColor;

    switch (mood) {
      case CharacterMood.dreamy:
        // Long flowing hair
        final hairPath = Path()
          ..moveTo(cx - 31, headY + 18)
          ..cubicTo(cx - 42, headY + 10, cx - 38, headY - 8, cx - 15, headY - 4)
          ..cubicTo(cx - 5, headY - 14, cx + 5, headY - 14, cx + 15, headY - 4)
          ..cubicTo(
              cx + 38, headY - 8, cx + 42, headY + 10, cx + 31, headY + 18)
          ..cubicTo(
              cx + 42, headY + 30, cx + 46, headY + 60, cx + 38, headY + 80)
          ..lineTo(cx + 30, headY + 80)
          ..cubicTo(
              cx + 38, headY + 55, cx + 34, headY + 30, cx + 26, headY + 18)
          ..lineTo(cx - 26, headY + 18)
          ..cubicTo(
              cx - 34, headY + 30, cx - 38, headY + 55, cx - 30, headY + 80)
          ..lineTo(cx - 38, headY + 80)
          ..cubicTo(
              cx - 46, headY + 60, cx - 42, headY + 30, cx - 31, headY + 18)
          ..close();
        canvas.drawPath(hairPath, hairPaint);

      case CharacterMood.bold:
        // Short messy hair
        final hairPath = Path()
          ..moveTo(cx - 31, headY + 20)
          ..cubicTo(cx - 40, headY + 5, cx - 36, headY - 10, cx - 10, headY - 8)
          ..cubicTo(cx - 2, headY - 20, cx + 2, headY - 20, cx + 14, headY - 12)
          ..cubicTo(
              cx + 22, headY - 18, cx + 28, headY - 10, cx + 24, headY - 2)
          ..cubicTo(cx + 40, headY, cx + 42, headY + 12, cx + 31, headY + 20)
          ..cubicTo(cx + 26, headY + 8, cx + 20, headY + 2, cx, headY + 0)
          ..cubicTo(cx - 20, headY + 2, cx - 26, headY + 8, cx - 31, headY + 20)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        // Spiky bits
        final spikePaint = Paint()..color = theme.characterHairColor;
        final spikes = Path()
          ..moveTo(cx - 8, headY - 8)
          ..lineTo(cx - 4, headY - 22)
          ..lineTo(cx + 2, headY - 8)
          ..moveTo(cx + 6, headY - 10)
          ..lineTo(cx + 12, headY - 24)
          ..lineTo(cx + 18, headY - 10);
        canvas.drawPath(spikes, spikePaint);

      case CharacterMood.scared:
        // Messy/wild standing up hair
        final hairPath = Path()
          ..moveTo(cx - 31, headY + 16)
          ..cubicTo(
              cx - 44, headY - 5, cx - 40, headY - 20, cx - 18, headY - 12)
          ..lineTo(cx - 22, headY - 28)
          ..lineTo(cx - 10, headY - 14)
          ..lineTo(cx - 6, headY - 30)
          ..lineTo(cx + 2, headY - 14)
          ..lineTo(cx + 8, headY - 32)
          ..lineTo(cx + 16, headY - 14)
          ..cubicTo(
              cx + 40, headY - 18, cx + 44, headY - 4, cx + 31, headY + 16)
          ..close();
        canvas.drawPath(hairPath, hairPaint);

      case CharacterMood.curious:
        // Side-swept professional hair
        final hairPath = Path()
          ..moveTo(cx - 31, headY + 22)
          ..cubicTo(cx - 42, headY + 8, cx - 40, headY - 10, cx - 20, headY - 8)
          ..cubicTo(
              cx - 30, headY - 20, cx - 10, headY - 22, cx + 10, headY - 16)
          ..cubicTo(cx + 30, headY - 10, cx + 42, headY, cx + 31, headY + 22)
          ..cubicTo(cx + 22, headY + 10, cx, headY + 6, cx - 22, headY + 10)
          ..close();
        canvas.drawPath(hairPath, hairPaint);

      case CharacterMood.focused:
        // Futuristic/sleek with streak
        final hairPath = Path()
          ..moveTo(cx - 31, headY + 20)
          ..cubicTo(
              cx - 40, headY + 4, cx - 38, headY - 12, cx - 16, headY - 10)
          ..cubicTo(cx - 8, headY - 18, cx + 8, headY - 18, cx + 16, headY - 10)
          ..cubicTo(
              cx + 38, headY - 12, cx + 40, headY + 4, cx + 31, headY + 20)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        // Glowing streak
        final streakPaint = Paint()
          ..color = theme.characterAccentColor.withValues(alpha: 0.8)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(cx + 4, headY - 18),
          Offset(cx + 10, headY + 2),
          streakPaint,
        );
    }
  }

  void _drawFace(Canvas canvas, double cx, double breathOffset) {
    final headY = 60.0 - breathOffset * 0.5;
    final eyeY = headY + 28.0;
    final eyeOpenness = blinkValue;

    // Eyes
    _drawEye(canvas, cx - 14, eyeY, eyeOpenness, isLeft: true);
    _drawEye(canvas, cx + 14, eyeY, eyeOpenness, isLeft: false);

    // Mouth based on mood
    _drawMouth(canvas, cx, headY + 44);

    // Nose
    final nosePaint = Paint()
      ..color = theme.characterSkinTone.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final nosePath = Path()
      ..moveTo(cx - 4, headY + 32)
      ..cubicTo(cx - 6, headY + 40, cx + 6, headY + 40, cx + 4, headY + 32);
    canvas.drawPath(nosePath, nosePaint);
  }

  void _drawEye(Canvas canvas, double x, double y, double openness,
      {required bool isLeft}) {
    // Eye white
    final eyeWhitePaint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(x, y),
          width: 14,
          height: 10 * openness.clamp(0.05, 1.0)),
      eyeWhitePaint,
    );

    if (openness > 0.1) {
      // Iris
      final irisPaint = Paint()..color = theme.primary.withValues(alpha: 0.9);
      canvas.drawCircle(Offset(x, y), 4 * openness.clamp(0.1, 1.0), irisPaint);

      // Pupil
      final pupilPaint = Paint()..color = Colors.black.withValues(alpha: 0.85);
      canvas.drawCircle(
          Offset(x, y), 2.2 * openness.clamp(0.1, 1.0), pupilPaint);

      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8);
      canvas.drawCircle(Offset(x + 1.5, y - 1.5), 1.2, highlightPaint);
    }

    // Eyelashes (top lid)
    final lashPaint = Paint()
      ..color = theme.characterHairColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (openness > 0.3) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, y), width: 16, height: 12),
        -3.14,
        3.14,
        false,
        lashPaint,
      );
    }
  }

  void _drawMouth(Canvas canvas, double cx, double mouthY) {
    final mouthPaint = Paint()
      ..color = theme.characterSkinTone.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    switch (mood) {
      case CharacterMood.dreamy:
        // Gentle smile
        final path = Path()
          ..moveTo(cx - 10, mouthY)
          ..cubicTo(cx - 5, mouthY + 7, cx + 5, mouthY + 7, cx + 10, mouthY);
        canvas.drawPath(path, mouthPaint);

      case CharacterMood.bold:
        // Confident smirk
        final path = Path()
          ..moveTo(cx - 8, mouthY + 2)
          ..cubicTo(cx - 2, mouthY + 6, cx + 6, mouthY + 5, cx + 10, mouthY);
        canvas.drawPath(path, mouthPaint);

      case CharacterMood.scared:
        // Open mouth "O" shape
        final path = Path()
          ..moveTo(cx - 7, mouthY)
          ..cubicTo(cx - 8, mouthY + 8, cx + 8, mouthY + 8, cx + 7, mouthY)
          ..cubicTo(cx + 8, mouthY - 4, cx - 8, mouthY - 4, cx - 7, mouthY);
        canvas.drawPath(path, mouthPaint..style = PaintingStyle.fill);
        canvas.drawPath(path, mouthPaint..style = PaintingStyle.stroke);

      case CharacterMood.curious:
        // Slight open curious mouth
        final path = Path()
          ..moveTo(cx - 9, mouthY + 1)
          ..cubicTo(cx - 4, mouthY + 5, cx + 4, mouthY + 5, cx + 9, mouthY + 1);
        canvas.drawPath(path, mouthPaint);

      case CharacterMood.focused:
        // Straight line, determined
        canvas.drawLine(
          Offset(cx - 9, mouthY + 2),
          Offset(cx + 9, mouthY + 2),
          mouthPaint,
        );
    }
  }

  void _drawAccessory(Canvas canvas, double cx, double breathOffset) {
    final headY = 60.0 - breathOffset * 0.5;

    switch (mood) {
      case CharacterMood.dreamy:
        // Small flower/petal in hair
        final petalPaint = Paint()
          ..color = theme.primary.withValues(alpha: 0.9);
        for (int i = 0; i < 5; i++) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(
                cx + 22 + (6 * (i % 2 == 0 ? 1 : -1) * 0.6),
                headY + 4 + (i * 2.0),
              ),
              width: 6,
              height: 4,
            ),
            petalPaint,
          );
        }

      case CharacterMood.bold:
        // Scar or badge mark
        final scarPaint = Paint()
          ..color = theme.primary.withValues(alpha: 0.6)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(cx + 16, headY + 24),
          Offset(cx + 22, headY + 32),
          scarPaint,
        );

      case CharacterMood.scared:
        // Sweat drop
        final sweatPaint = Paint()
          ..color = const Color(0xFF93C5FD).withValues(alpha: 0.7);
        final sweatPath = Path()
          ..moveTo(cx + 28, headY + 18)
          ..cubicTo(
              cx + 32, headY + 22, cx + 34, headY + 28, cx + 28, headY + 28)
          ..cubicTo(
              cx + 24, headY + 28, cx + 24, headY + 22, cx + 28, headY + 18);
        canvas.drawPath(sweatPath, sweatPaint);

      case CharacterMood.curious:
        // Small magnifying glass near eye
        final glassPaint = Paint()
          ..color = theme.primary.withValues(alpha: 0.6)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(cx + 26, headY + 16), 5, glassPaint);
        canvas.drawLine(
          Offset(cx + 30, headY + 20),
          Offset(cx + 35, headY + 25),
          glassPaint,
        );

      case CharacterMood.focused:
        // Visor/glasses
        final glassPaint = Paint()
          ..color = theme.primary.withValues(alpha: 0.5)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx - 14, headY + 28), width: 16, height: 10),
            const Radius.circular(3),
          ),
          glassPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx + 14, headY + 28), width: 16, height: 10),
            const Radius.circular(3),
          ),
          glassPaint,
        );
        canvas.drawLine(
          Offset(cx - 6, headY + 28),
          Offset(cx + 6, headY + 28),
          glassPaint,
        );
        // Lens glow
        final glowPaint = Paint()
          ..color = theme.primary.withValues(alpha: 0.15);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx - 14, headY + 28), width: 14, height: 8),
            const Radius.circular(2),
          ),
          glowPaint,
        );
    }
  }

  @override
  bool shouldRepaint(_CharacterPainter old) =>
      old.breathValue != breathValue ||
      old.blinkValue != blinkValue ||
      old.pageValue != pageValue ||
      old.isReading != isReading;
}
