import 'package:flutter/material.dart';

enum CharacterMood { dreamy, bold, scared, curious, focused }

class StoryTheme {
  final String id;
  final String name;
  final String emoji;
  final String tagline;
  final Color primary;
  final Color background;
  final Color surface;
  final Color cardColor;
  final List<Color> gradientColors;
  final List<Color> orbColors;

  // Character appearance
  final Color characterSkinTone;
  final Color characterHairColor;
  final Color characterClothingColor;
  final Color characterAccentColor;
  final CharacterMood characterMood;

  final String systemPrompt;
  final List<String> starters;

  const StoryTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.tagline,
    required this.primary,
    required this.background,
    required this.surface,
    required this.cardColor,
    required this.gradientColors,
    required this.orbColors,
    required this.characterSkinTone,
    required this.characterHairColor,
    required this.characterClothingColor,
    required this.characterAccentColor,
    required this.characterMood,
    required this.systemPrompt,
    required this.starters,
  });
}
