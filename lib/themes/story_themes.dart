import 'package:flutter/material.dart';
import '../models/story_theme.dart';

const loveTheme = StoryTheme(
  id: 'love',
  name: 'Love',
  emoji: '🌹',
  tagline: 'Hearts, longing & tender moments',
  primary: Color(0xFFE8849A),
  background: Color(0xFF1C0F14),
  surface: Color(0xFF2A1A20),
  cardColor: Color(0xFF3A242C),
  gradientColors: [
    Color(0xFF1C0F14),
    Color(0xFF2A1A20),
    Color(0xFF14080F),
  ],
  orbColors: [
    Color(0xFFBE185D),
    Color(0xFF9D174D),
  ],
  characterSkinTone: Color(0xFFF4C2A1),
  characterHairColor: Color(0xFF8B4513),
  characterClothingColor: Color(0xFFE8849A),
  characterAccentColor: Color(0xFFFF6B9D),
  characterMood: CharacterMood.dreamy,
  systemPrompt:
      'You are a romantic story narrator. Write in a poetic, emotionally rich style. '
      'Stories involve love, longing, connection, heartbreak, and tender moments. '
      'Use evocative, literary language. Keep each story segment to 3-4 sentences. '
      'Always end by offering exactly 3 choices (labeled A, B, C) for what happens next. '
      'Format choices as:\nA) [choice]\nB) [choice]\nC) [choice]',
  starters: [
    'A letter arrives with no return address',
    'You see a familiar stranger at the café',
    'A forgotten photograph falls from an old book',
  ],
);

const adventureTheme = StoryTheme(
  id: 'adventure',
  name: 'Adventure',
  emoji: '⚔️',
  tagline: 'Quests, danger & epic triumph',
  primary: Color(0xFF4ADE80),
  background: Color(0xFF0C1410),
  surface: Color(0xFF16201A),
  cardColor: Color(0xFF1F2A24),
  gradientColors: [
    Color(0xFF0C1410),
    Color(0xFF16201A),
    Color(0xFF060C08),
  ],
  orbColors: [
    Color(0xFF15803D),
    Color(0xFF166534),
  ],
  characterSkinTone: Color(0xFFD4956A),
  characterHairColor: Color(0xFF1A0A00),
  characterClothingColor: Color(0xFF2D5016),
  characterAccentColor: Color(0xFF4ADE80),
  characterMood: CharacterMood.bold,
  systemPrompt:
      'You are an epic adventure story narrator. Write in a bold, action-packed style. '
      'Stories involve heroes, quests, danger, ancient mysteries, and triumph. '
      'Keep the pace fast and exciting. Keep each segment to 3-4 sentences. '
      'Always end by offering exactly 3 choices (labeled A, B, C) for what happens next. '
      'Format choices as:\nA) [choice]\nB) [choice]\nC) [choice]',
  starters: [
    'A treasure map appears under your door at dawn',
    'The dragon\'s roar echoes from the forbidden mountain',
    'The ancient rune on your hand begins to glow',
  ],
);

const creepyTheme = StoryTheme(
  id: 'creepy',
  name: 'Creepy',
  emoji: '🕯️',
  tagline: 'Dread, mystery & the unknown',
  primary: Color(0xFFA78BFA),
  background: Color(0xFF0A070F),
  surface: Color(0xFF13101C),
  cardColor: Color(0xFF1C1928),
  gradientColors: [
    Color(0xFF0A070F),
    Color(0xFF13101C),
    Color(0xFF05040A),
  ],
  orbColors: [
    Color(0xFF6D28D9),
    Color(0xFF4C1D95),
  ],
  characterSkinTone: Color(0xFFD4C5B0),
  characterHairColor: Color(0xFF1A1A1A),
  characterClothingColor: Color(0xFF1A1030),
  characterAccentColor: Color(0xFFA78BFA),
  characterMood: CharacterMood.scared,
  systemPrompt:
      'You are a horror story narrator in the tradition of Poe and Lovecraft. '
      'Write with dread, atmosphere, and psychological tension. '
      'Stories involve the uncanny, paranoia, strange phenomena, and creeping horror. '
      'Keep each segment to 3-4 sentences. '
      'Always end by offering exactly 3 choices (labeled A, B, C) for what happens next. '
      'Format choices as:\nA) [choice]\nB) [choice]\nC) [choice]',
  starters: [
    'The mirror in your room shows a different reflection',
    'Your neighbor\'s house has been silent for three weeks',
    'A child\'s laughter echoes from the basement — you live alone',
  ],
);

const mysteryTheme = StoryTheme(
  id: 'mystery',
  name: 'Mystery',
  emoji: '🔍',
  tagline: 'Clues, deception & the truth',
  primary: Color(0xFFFBBF24),
  background: Color(0xFF12100A),
  surface: Color(0xFF1E1A12),
  cardColor: Color(0xFF29251B),
  gradientColors: [
    Color(0xFF12100A),
    Color(0xFF1E1A12),
    Color(0xFF0A0805),
  ],
  orbColors: [
    Color(0xFFB45309),
    Color(0xFF92400E),
  ],
  characterSkinTone: Color(0xFFE8C99A),
  characterHairColor: Color(0xFF3D2B1F),
  characterClothingColor: Color(0xFF292215),
  characterAccentColor: Color(0xFFFBBF24),
  characterMood: CharacterMood.curious,
  systemPrompt:
      'You are a noir mystery story narrator. Write in a sharp, suspenseful style. '
      'Stories involve detectives, secrets, lies, unexpected twists, and revelations. '
      'Use atmospheric, cinematic language. Keep each segment to 3-4 sentences. '
      'Always end by offering exactly 3 choices (labeled A, B, C) for what happens next. '
      'Format choices as:\nA) [choice]\nB) [choice]\nC) [choice]',
  starters: [
    'The detective\'s file lands on your desk — your name is in it',
    'A key taped beneath a park bench — no one knows you found it',
    'The witness changes their story for the third time',
  ],
);

const scifiTheme = StoryTheme(
  id: 'scifi',
  name: 'Sci-Fi',
  emoji: '🚀',
  tagline: 'Space, AI & futures unknown',
  primary: Color(0xFF38BDF8),
  background: Color(0xFF020C12),
  surface: Color(0xFF08161F),
  cardColor: Color(0xFF0F1F2B),
  gradientColors: [
    Color(0xFF020C12),
    Color(0xFF08161F),
    Color(0xFF01070F),
  ],
  orbColors: [
    Color(0xFF0369A1),
    Color(0xFF075985),
  ],
  characterSkinTone: Color(0xFFB8D4E8),
  characterHairColor: Color(0xFF00C8FF),
  characterClothingColor: Color(0xFF0A2540),
  characterAccentColor: Color(0xFF38BDF8),
  characterMood: CharacterMood.focused,
  systemPrompt:
      'You are a science fiction story narrator. Write in a vivid, imaginative style. '
      'Stories involve space exploration, artificial intelligence, dystopias, alien encounters, '
      'and humanity\'s future. Keep each segment to 3-4 sentences. '
      'Always end by offering exactly 3 choices (labeled A, B, C) for what happens next. '
      'Format choices as:\nA) [choice]\nB) [choice]\nC) [choice]',
  starters: [
    'The AI on your ship says something it was never programmed to say',
    'The signal from deep space has been repeating for 40 years — until now',
    'You wake from cryo-sleep. The crew is gone. The planet below is not Earth.',
  ],
);

final List<StoryTheme> storyThemes = [
  scifiTheme,
  adventureTheme,
  creepyTheme,
  loveTheme,
  mysteryTheme,
];
