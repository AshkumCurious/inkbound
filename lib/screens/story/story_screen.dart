import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ai_service.dart';
import '../../models/quiz_question.dart';
import '../../models/story_state.dart';
import '../../models/story_theme.dart';
import '../../themes/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../vocabulary_screen.dart';
import 'widgets/character_panel.dart';
import 'widgets/choice_button.dart';
import 'widgets/definition_bottom_sheet.dart';
import 'widgets/interactive_story_text.dart';
import 'widgets/quiz_question_card.dart';
import 'widgets/starter_card.dart';
import 'widgets/theme_tag.dart';

class StoryScreen extends StatefulWidget {
  final StoryTheme theme;
  const StoryScreen({super.key, required this.theme});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  StoryState _storyState = const StoryState();
  final ScrollController _scrollController = ScrollController();
  bool _showStarters = true;
  bool _characterVisible = true;

  final TextEditingController _customPromptController = TextEditingController();
  bool _isCustomStarting = false;

  // Quiz Related
  bool _showQuiz = false;
  List<QuizQuestion> _quizQuestions = [];
  List<int> _selectedAnswers = [];
  bool _quizSubmitted = false;
  int _score = 0;

  StoryTheme get t => widget.theme;

  @override
  void dispose() {
    _scrollController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  // ==================== Quiz Logic ====================
  Future<void> _triggerQuiz() async {
    setState(() => _showQuiz = true);
    await _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    setState(() => _quizQuestions = []); // loading state

    try {
      final questions = await ClaudeService.generateQuiz(
        theme: t,
        storyHistory: _storyState.segments,
      );

      setState(() {
        _quizQuestions = questions.cast<QuizQuestion>();
        _selectedAnswers = List.filled(questions.length, -1);
        _quizSubmitted = false;
        _score = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate quiz: $e')),
      );
      setState(() => _showQuiz = false);
    }
  }

  void _submitQuiz() {
    int correct = 0;
    for (int i = 0; i < _quizQuestions.length; i++) {
      if (_selectedAnswers[i] == _quizQuestions[i].correctIndex) correct++;
    }
    setState(() {
      _score = correct;
      _quizSubmitted = true;
    });
  }

  void _continueStory() {
    setState(() {
      _showQuiz = false;
      _quizQuestions = [];
      _selectedAnswers = [];
      _quizSubmitted = false;
    });
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  Future<void> _showWordDefinition(String word) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DefinitionBottomSheet(word: word, theme: t),
    );
  }

  Future<void> _startStory(String starter) async {
    setState(() {
      _showStarters = false;
      _characterVisible = true;
      _storyState = _storyState.copyWith(isLoading: true, error: null);
    });

    try {
      final segment = await ClaudeService.generateStory(
        theme: t,
        prompt: starter,
        history: [],
      );
      setState(() {
        _storyState = StoryState(segments: [segment], isLoading: false);
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _storyState =
            _storyState.copyWith(isLoading: false, error: e.toString());
        _showStarters = true;
      });
    }
  }

  Future<void> _startCustomStory() async {
    final prompt = _customPromptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isCustomStarting = true;
      _showStarters = false;
      _characterVisible = true;
      _storyState = _storyState.copyWith(isLoading: true, error: null);
    });

    try {
      final segment = await ClaudeService.generateStory(
        theme: t,
        prompt: prompt,
        history: [],
      );
      setState(() {
        _storyState = StoryState(segments: [segment], isLoading: false);
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _storyState =
            _storyState.copyWith(isLoading: false, error: e.toString());
        _showStarters = true;
        _isCustomStarting = false;
      });
    }
  }

  Future<void> _makeChoice(int choiceIndex) async {
    final current = _storyState.currentSegment!;
    final choice = current.choices[choiceIndex];

    // Update the last segment with chosen choice
    final updated = List<StorySegment>.from(_storyState.segments);
    updated[updated.length - 1] = current.copyWith(choiceMade: choice);

    setState(() {
      _storyState = StoryState(segments: updated, isLoading: true);
    });

    _scrollToBottom();

    try {
      final next = await ClaudeService.generateStory(
        theme: t,
        prompt: '',
        history: updated,
      );

      setState(() {
        _storyState =
            StoryState(segments: [...updated, next], isLoading: false);
      });

      _scrollToBottom();

      if (_storyState.segments.length >= 3 &&
          _storyState.segments.length % 3 == 0 &&
          !_showQuiz) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted && !_showQuiz) {
            _triggerQuiz();
          }
        });
      }
    } catch (e) {
      setState(() {
        _storyState =
            _storyState.copyWith(isLoading: false, error: e.toString());
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _restart() {
    setState(() {
      _storyState = const StoryState();
      _showStarters = true;
      _characterVisible = true;
      _customPromptController.clear();
      _isCustomStarting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: t.gradientColors,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: GlowOrb(
                  color: t.orbColors[0].withValues(alpha: 0.25), size: 260),
            ),
            Positioned(
              bottom: -140,
              left: -90,
              child: GlowOrb(
                  color: t.orbColors[1].withValues(alpha: 0.18), size: 300),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: _showStarters
                        ? _buildStarterView()
                        : _showQuiz
                            ? _buildQuizView()
                            : _buildStoryView(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizView() {
    final bool isLoading = _quizQuestions.isEmpty;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.primary.withValues(alpha: 0.12),
                  border: Border.all(color: t.primary.withValues(alpha: 0.3)),
                ),
                child:
                    Icon(Icons.psychology_rounded, color: t.primary, size: 24),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.4, 0.4),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.elasticOut,
                    duration: 700.ms,
                  )
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 14),
              Text(
                "Quick Comprehension Check",
                style: AppTextStyles.displayMedium(),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
              const SizedBox(height: 6),
              Text(
                "Let's see how well you remember the story",
                style: AppTextStyles.label(size: 15),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 350.ms, duration: 500.ms),
            ],
          ),

          const SizedBox(height: 30),

          // Questions or loading skeleton
          Expanded(
            child: isLoading
                ? _buildQuizSkeleton()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _quizQuestions.length,
                    itemBuilder: (context, index) {
                      final q = _quizQuestions[index];
                      return QuizQuestionCard(
                        question: q,
                        index: index,
                        selectedAnswer: _selectedAnswers[index],
                        onAnswerSelected: (ansIndex) {
                          setState(() => _selectedAnswers[index] = ansIndex);
                        },
                        isSubmitted: _quizSubmitted,
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: index * 120),
                            duration: 500.ms,
                          )
                          .slideY(
                            begin: 0.15,
                            end: 0,
                            delay: Duration(milliseconds: index * 120),
                            curve: Curves.easeOut,
                          );
                    },
                  ),
          ),

          // Score
          if (_quizSubmitted)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                "Your Score: $_score / ${_quizQuestions.length}",
                style: AppTextStyles.displaySmall(color: t.primary),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.85, 0.85)),
            ),

          // Button
          if (!isLoading)
            Row(
              children: [
                if (_quizSubmitted)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _continueStory,
                      child: const Text("Continue Story"),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _selectedAnswers.contains(-1) ? null : _submitQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: t.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Submit Quiz",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
        ],
      ),
    );
  }

  Widget _buildQuizSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: t.cardColor,
            border: Border.all(color: t.primary.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question line
              _skeletonBar(double.infinity, 14, index, 0),
              const SizedBox(height: 6),
              _skeletonBar(200, 14, index, 60),
              const SizedBox(height: 20),
              // Answer options
              ...[0, 1, 2, 3].map((i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        _skeletonCircle(18, index, 120 + i * 40),
                        const SizedBox(width: 12),
                        _skeletonBar(160, 12, index, 130 + i * 40),
                      ],
                    ),
                  )),
            ],
          ),
        ).animate().fadeIn(
              delay: Duration(milliseconds: index * 100),
              duration: 400.ms,
            );
      },
    );
  }

  Widget _skeletonBar(double width, double height, int card, int extraDelay) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: t.primary.withValues(alpha: 0.08),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
          delay: Duration(milliseconds: card * 80 + extraDelay),
          duration: 1200.ms,
          color: t.primary.withValues(alpha: 0.15),
        );
  }

  Widget _skeletonCircle(double size, int card, int extraDelay) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.primary.withValues(alpha: 0.08),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
          delay: Duration(milliseconds: card * 80 + extraDelay),
          duration: 1200.ms,
          color: t.primary.withValues(alpha: 0.15),
        );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
            color: t.primary,
          ),
          const SizedBox(width: 16),
          Text(t.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Text(t.name, style: AppTextStyles.displaySmall()),
          const Spacer(),
          if (_storyState.hasStory) ...[
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VocabularyScreen()),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: t.primary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bookmark, size: 18),
                    SizedBox(width: 6),
                    Text('Vocab', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _restart,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: t.primary.withValues(alpha: 0.3)),
                ),
                child: Text('Restart Story',
                    style: AppTextStyles.label(color: t.primary, size: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarterView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Character
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, bottom: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CharacterPanel(theme: t, isLoading: false),
                const Spacer(),
                ThemeTag(theme: t),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Starters + Custom Input
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Where does\nit begin?',
                    style: AppTextStyles.displayLarge(),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Pick your opening scene',
                    style: AppTextStyles.label(
                        color: t.primary.withValues(alpha: 0.6)),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 28),

                  // Pre-made Starters
                  ...t.starters.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: StarterCard(
                          text: e.value,
                          theme: t,
                          onTap: () => _startStory(e.value),
                          delay: Duration(milliseconds: 150 + e.key * 100),
                        ),
                      )),

                  const SizedBox(height: 32),

                  // Custom Prompt Section
                  Text(
                    'Or write your own beginning',
                    style: AppTextStyles.labelMedium(
                        color: t.primary.withValues(alpha: 0.8), size: 15),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: t.cardColor,
                      border:
                          Border.all(color: t.primary.withValues(alpha: 0.2)),
                    ),
                    child: TextField(
                      controller: _customPromptController,
                      onChanged: (_) => setState(() {}),
                      maxLength: 100,
                      maxLines: 3,
                      style: AppTextStyles.label(
                          size: 15, color: AppColors.parchment),
                      decoration: InputDecoration(
                        hintText: "A mysterious stranger knocks at midnight...",
                        hintStyle: AppTextStyles.label(
                            size: 15, color: AppColors.parchment70),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                        counterText: "",
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${100 - _customPromptController.text.length} left',
                        style: AppTextStyles.mono(
                            size: 12, color: t.primary.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _customPromptController.text.trim().isEmpty ||
                              _isCustomStarting
                          ? null
                          : _startCustomStory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: t.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _isCustomStarting
                            ? 'Starting...'
                            : 'Begin Custom Story',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  if (_storyState.error != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red.withValues(alpha: 0.08),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        _storyState.error!,
                        style: GoogleFonts.spaceMono(
                            fontSize: 11, color: Colors.red.shade300),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryView() {
    return Column(
      children: [
        // const SizedBox(height: 12),
        if (_characterVisible)
          CharacterPanel(
                  theme: t, isLoading: _storyState.isLoading, compact: true)
              .animate()
              .fadeIn(duration: 500.ms),
        const SizedBox(height: 8),
        ThemedDivider(theme: t),
        Expanded(
          child: ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(8, 20, 24, 4),
            children: [
              ..._storyState.segments.asMap().entries.map((e) {
                final isLast = e.key == _storyState.segments.length - 1;
                return StorySegmentWidget(
                  segment: e.value,
                  theme: t,
                  isLast: isLast && !_storyState.isLoading,
                  onChoice: isLast ? _makeChoice : null,
                );
              }),
              if (_storyState.isLoading) _buildLoader(),
              if (_storyState.error != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red.withValues(alpha: 0.08),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    _storyState.error!,
                    style: GoogleFonts.spaceMono(
                        fontSize: 11, color: Colors.red.shade300),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                3,
                (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: t.primary),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .fadeIn(
                              delay: Duration(milliseconds: i * 150),
                              duration: 400.ms)
                          .then()
                          .fadeOut(duration: 400.ms),
                    )),
          ),
          const SizedBox(height: 10),
          Text(
            'Weaving the next chapter...',
            style: AppTextStyles.label(
                color: t.primary.withValues(alpha: 0.4), size: 13),
          ),
        ],
      ),
    );
  }
}

class StorySegmentWidget extends StatelessWidget {
  final StorySegment segment;
  final StoryTheme theme;
  final bool isLast;
  final void Function(int)? onChoice;

  const StorySegmentWidget({
    super.key,
    required this.segment,
    required this.theme,
    required this.isLast,
    this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: t.primary.withValues(alpha: 0.12), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 60,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: InteractiveStoryText(
            text: segment.text,
            theme: t,
            onWordTap: (word) {
              if (word.length > 2) {
                (context
                        .findAncestorStateOfType<_StoryScreenState>()
                        ?._showWordDefinition(word)) ??
                    ();
              }
            },
          ),
        ),
        if (segment.choiceMade != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 20),
            child: Row(
              children: [
                Icon(Icons.bookmark,
                    size: 18, color: t.primary.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    segment.choiceMade!,
                    style: AppTextStyles.label(
                        color: t.primary.withValues(alpha: 0.75), size: 13.5),
                  ),
                ),
              ],
            ),
          ),
        if (isLast && segment.choices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 16),
                  child: Text(
                    'WHAT HAPPENS NEXT?',
                    style: AppTextStyles.overline(color: t.primary),
                  ),
                ),
                ...segment.choices.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: ChoiceButton(
                        label: String.fromCharCode(65 + e.key),
                        text: e.value,
                        theme: t,
                        onTap: () => onChoice!(e.key),
                      ),
                    )),
              ],
            ),
          )
        else
          const SizedBox(height: 20),
      ],
    );
  }
}
