// lib/screens/quiz/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../providers/category_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/quiz/option_button.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String? categoryId;

  const QuizScreen({super.key, this.categoryId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _setupMode = true;
  int _questionCount = 10;
  bool _timerEnabled = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) _setupMode = false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final catProvider = context.watch<CategoryProvider>();

    if (_setupMode || (provider.state == QuizState.idle && widget.categoryId == null)) {
      return _QuizSetupView(
        categories: catProvider.categories,
        initialCategoryId: widget.categoryId,
        questionCount: _questionCount,
        timerEnabled: _timerEnabled,
        onCountChanged: (v) => setState(() => _questionCount = v),
        onTimerChanged: (v) => setState(() => _timerEnabled = v),
        onStart: (catId) async {
          setState(() => _setupMode = false);
          final user = context.read<AuthProvider>().currentUser;
          await provider.loadQuiz(
            categoryId: catId,
            userId: user?.id,
            questionCount: _questionCount,
            enableTimer: _timerEnabled,
          );
        },
      );
    }

    if (provider.state == QuizState.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.state == QuizState.complete) {
      return QuizResultScreen(provider: provider);
    }

    if (provider.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Mode')),
        body: const EmptyState(
          icon: Icons.quiz_outlined,
          title: 'Not Enough Cards',
          description: 'You need at least 2 flashcards to take a quiz.',
        ),
      );
    }

    final q = provider.currentQuestion!;
    final letters = ['A', 'B', 'C', 'D'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${provider.currentIndex + 1}/${provider.totalQuestions}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: provider.totalQuestions == 0
                ? 0
                : (provider.currentIndex + 1) / provider.totalQuestions,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                // Timer (if enabled)
                if (provider.timerEnabled) ...[
                  _TimerWidget(remaining: provider.remainingSeconds, total: provider.timerSeconds),
                  const SizedBox(height: AppSizes.md),
                ],

                // Question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Question',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        q.flashcard.question,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Options
                ...q.options.asMap().entries.map((entry) {
                  final i = entry.key;
                  final option = entry.value;
                  OptionState state = OptionState.idle;
                  if (q.isAnswered) {
                    if (i == q.correctIndex) {
                      state = OptionState.correct;
                    } else if (i == q.selectedOptionIndex) {
                      state = OptionState.wrong;
                    }
                  }
                  return OptionButton(
                    label: option,
                    optionLetter: letters[i],
                    state: state,
                    onTap: () => provider.answerQuestion(i),
                  );
                }),

                // Next button (after answering)
                if (q.isAnswered) ...[
                  const SizedBox(height: AppSizes.md),
                  // Correct/wrong feedback
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: q.isCorrect
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: Border.all(
                        color: q.isCorrect
                            ? AppColors.success.withOpacity(0.4)
                            : AppColors.error.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          q.isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: q.isCorrect
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.isCorrect ? 'Correct!' : 'Incorrect',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: q.isCorrect
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                              if (!q.isCorrect)
                                Text(
                                  'Answer: ${q.correctAnswer}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.error,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final user = context.read<AuthProvider>().currentUser;
                        provider.nextQuestion(userId: user?.id);
                      },
                      child: Text(
                        provider.currentIndex < provider.totalQuestions - 1
                            ? 'Next Question →'
                            : 'See Results',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Score bar
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ScoreStat(
                  label: 'Correct',
                  value: '${provider.correctCount}',
                  color: AppColors.success,
                ),
                _ScoreStat(
                  label: 'Remaining',
                  value:
                      '${provider.totalQuestions - provider.currentIndex - (provider.currentQuestion?.isAnswered == true ? 1 : 0)}',
                  color: AppColors.primary,
                ),
                _ScoreStat(
                  label: 'Score',
                  value: '${provider.score.toStringAsFixed(0)}%',
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerWidget extends StatelessWidget {
  final int remaining;
  final int total;
  const _TimerWidget({required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : remaining / total;
    final color = fraction > 0.5
        ? AppColors.success
        : fraction > 0.25
            ? AppColors.warning
            : AppColors.error;

    return Row(
      children: [
        Icon(Icons.timer_rounded, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          '$remaining s',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: color,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

class _QuizSetupView extends StatefulWidget {
  final List categories;
  final String? initialCategoryId;
  final int questionCount;
  final bool timerEnabled;
  final void Function(int) onCountChanged;
  final void Function(bool) onTimerChanged;
  final void Function(String?) onStart;

  const _QuizSetupView({
    required this.categories,
    required this.initialCategoryId,
    required this.questionCount,
    required this.timerEnabled,
    required this.onCountChanged,
    required this.onTimerChanged,
    required this.onStart,
  });

  @override
  State<_QuizSetupView> createState() => _QuizSetupViewState();
}

class _QuizSetupViewState extends State<_QuizSetupView> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Mode',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            ),
            child: Column(
              children: [
                const Icon(Icons.quiz_rounded, color: Colors.white, size: 48),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Ready to test yourself?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Configure your quiz below',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // Category picker
          Text('Category',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: AppSizes.xs),
          DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            hint: const Text('All Categories'),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: [
              const DropdownMenuItem(
                  value: null, child: Text('All Categories')),
              ...widget.categories.map((cat) => DropdownMenuItem(
                    value: cat.id as String,
                    child: Text(cat.name as String),
                  )),
            ],
            onChanged: (v) => setState(() => _selectedCategoryId = v),
          ),
          const SizedBox(height: AppSizes.md),

          // Number of questions
          Row(
            children: [
              Text('Questions: ${widget.questionCount}',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              Text('${widget.questionCount}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 16)),
            ],
          ),
          Slider(
            value: widget.questionCount.toDouble(),
            min: 5,
            max: 30,
            divisions: 5,
            label: '${widget.questionCount}',
            onChanged: (v) => widget.onCountChanged(v.toInt()),
          ),
          const SizedBox(height: AppSizes.md),

          // Timer toggle
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppSizes.xs),
              title: Text('Enable Timer (30s per question)',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              secondary: const Icon(Icons.timer_rounded),
              value: widget.timerEnabled,
              onChanged: widget.onTimerChanged,
            ),
          ),
          const SizedBox(height: AppSizes.xxl),

          // Start button
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => widget.onStart(_selectedCategoryId),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
