import 'package:flutter/material.dart';
import '../../models/story_theme.dart';

class MiniCharacter extends StatelessWidget {
  final StoryTheme theme;

  const MiniCharacter({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.surface,
        border: Border.all(color: theme.primary.withValues(alpha: 0.25)),
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: MiniCharacterPainter(theme: theme),
          size: const Size(52, 52),
        ),
      ),
    );
  }
}

class MiniCharacterPainter extends CustomPainter {
  final StoryTheme theme;
  const MiniCharacterPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 16), width: 28, height: 22),
        const Radius.circular(6),
      ),
      Paint()..color = theme.characterClothingColor,
    );

    // Head
    canvas.drawCircle(
        Offset(cx, cy + 2), 14, Paint()..color = theme.characterSkinTone);

    // Hair
    canvas.drawCircle(
      Offset(cx, cy - 6),
      11,
      Paint()..color = theme.characterHairColor,
    );

    // Eyes
    canvas.drawCircle(
        Offset(cx - 5, cy + 2), 2.5, Paint()..color = theme.primary);
    canvas.drawCircle(
        Offset(cx + 5, cy + 2), 2.5, Paint()..color = theme.primary);
    canvas.drawCircle(
        Offset(cx - 5, cy + 2), 1.2, Paint()..color = Colors.black);
    canvas.drawCircle(
        Offset(cx + 5, cy + 2), 1.2, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(MiniCharacterPainter old) => false;
}
