import '../exports.dart';

class ThemeTag extends StatelessWidget {
  final StoryTheme theme;
  const ThemeTag({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.primary.withValues(alpha: 0.1),
        border: Border.all(color: theme.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        theme.tagline,
        textAlign: TextAlign.center,
        style: AppTextStyles.label(
            color: theme.primary.withValues(alpha: 0.8), size: 11),
      ),
    );
  }
}
