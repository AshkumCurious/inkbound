import '../exports.dart';

class StarterCard extends StatefulWidget {
  final String text;
  final StoryTheme theme;
  final VoidCallback onTap;
  final Duration delay;

  const StarterCard({
    super.key,
    required this.text,
    required this.theme,
    required this.onTap,
    required this.delay,
  });

  @override
  State<StarterCard> createState() => StarterCardState();
}

class StarterCardState extends State<StarterCard> {
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _hovered ? t.surface : t.cardColor,
            border: Border.all(
              color: _hovered
                  ? t.primary.withValues(alpha: 0.45)
                  : t.primary.withValues(alpha: 0.12),
              width: _hovered ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    height: 1.5,
                    // fontStyle: FontStyle.italic,
                    color: AppColors.parchment90,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.east_rounded, color: t.primary, size: 16),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: widget.delay, duration: 450.ms)
        .slideX(begin: 0.04, end: 0);
  }
}
