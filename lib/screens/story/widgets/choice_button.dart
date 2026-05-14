import '../exports.dart';

class ChoiceButton extends StatefulWidget {
  final String label;
  final String text;
  final StoryTheme theme;
  final VoidCallback onTap;

  const ChoiceButton({
    super.key,
    required this.label,
    required this.text,
    required this.theme,
    required this.onTap,
  });

  @override
  State<ChoiceButton> createState() => ChoiceButtonState();
}

class ChoiceButtonState extends State<ChoiceButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _hovered ? t.surface : t.cardColor,
            border: Border.all(
              color: _hovered
                  ? t.primary.withValues(alpha: 0.6)
                  : t.primary.withValues(alpha: 0.18),
              width: _hovered ? 1.8 : 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChoiceLabel(label: widget.label, color: t.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.text,
                  style: AppTextStyles.label(
                    color:
                        _hovered ? AppColors.parchment : AppColors.parchment70,
                    size: 15.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
