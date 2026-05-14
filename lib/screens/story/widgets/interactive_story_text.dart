import '../exports.dart';

class InteractiveStoryText extends StatelessWidget {
  final String text;
  final StoryTheme theme;
  final Function(String) onWordTap;

  const InteractiveStoryText({
    super.key,
    required this.text,
    required this.theme,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    final spans = <TextSpan>[];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();

      spans.add(TextSpan(
        text: word + (i < words.length - 1 ? ' ' : ''),
        style: AppTextStyles.storyBody().copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          decorationColor: theme.primary.withValues(alpha: 0.3),
          decorationThickness: 1.2,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => onWordTap(cleanWord.isNotEmpty ? word : ''),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
