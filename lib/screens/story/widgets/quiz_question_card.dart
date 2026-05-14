import '../exports.dart';

class QuizQuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int index;
  final int selectedAnswer;
  final Function(int) onAnswerSelected;
  final bool isSubmitted;

  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.isSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Q${index + 1}. ${question.question}",
            style: AppTextStyles.label(size: 16, color: Colors.white),
          ),
          const SizedBox(height: 16),
          ...question.options.asMap().entries.map((e) {
            final isCorrect = e.key == question.correctIndex;
            final isSelected = e.key == selectedAnswer;

            return GestureDetector(
              onTap: isSubmitted ? null : () => onAnswerSelected(e.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSubmitted
                      ? (isCorrect
                          ? Colors.green.withValues(alpha: 0.2)
                          : (isSelected
                              ? Colors.red.withValues(alpha: 0.2)
                              : null))
                      : (isSelected
                          ? Colors.white.withValues(alpha: 0.1)
                          : null),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSubmitted && isCorrect
                        ? Colors.green
                        : isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(e.value),
              ),
            );
          }),
          if (isSubmitted && question.explanation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                "Explanation: ${question.explanation}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
