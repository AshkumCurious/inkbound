import '../exports.dart';

class CharacterPanel extends StatelessWidget {
  final StoryTheme theme;
  final bool isLoading;
  final bool compact;

  const CharacterPanel({
    super.key,
    required this.theme,
    required this.isLoading,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final charSize = compact ? 110.0 : 180.0;
    final charHeight = compact ? 200.0 : 220.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: charSize,
          height: charHeight,
          child: StoryReaderCharacter(
            theme: theme,
            isReading: true,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(height: 6),
        if (!compact)
          Text(
            _moodLabel(theme.characterMood),
            style: AppTextStyles.label(
              color: theme.primary.withValues(alpha: 0.6),
              size: 12,
            ),
          ),
        if (isLoading && compact) ...[
          const SizedBox(height: 4),
          Text(
            'reading...',
            style: AppTextStyles.label(
              color: theme.primary.withValues(alpha: 0.5),
              size: 11,
            ),
          ),
        ],
      ],
    );
  }

  String _moodLabel(CharacterMood mood) {
    switch (mood) {
      case CharacterMood.dreamy:
        return 'lost in longing';
      case CharacterMood.bold:
        return 'ready for battle';
      case CharacterMood.scared:
        return 'heart in throat';
      case CharacterMood.curious:
        return 'searching for truth';
      case CharacterMood.focused:
        return 'scanning the void';
    }
  }
}
