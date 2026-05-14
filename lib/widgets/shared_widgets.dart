import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/story_theme.dart';

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

class GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const GlowOrb({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 130, spreadRadius: 35),
          ],
        ),
      ),
    );
  }
}

class SolidCard extends StatelessWidget {
  final Widget child;
  final StoryTheme theme;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool highlighted;

  const SolidCard({
    super.key,
    required this.child,
    required this.theme,
    this.padding,
    this.borderRadius,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        color: theme.cardColor,
        border: Border.all(
          color: highlighted
              ? theme.primary.withValues(alpha: 0.35)
              : theme.primary.withValues(alpha: 0.1),
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: child,
    );
  }
}

class ChoiceLabel extends StatelessWidget {
  final String label;
  final Color color;

  const ChoiceLabel({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

class ThemedDivider extends StatelessWidget {
  final StoryTheme theme;

  const ThemedDivider({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: theme.primary.withValues(alpha: 0.08),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primary.withValues(alpha: 0.3),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: theme.primary.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}
