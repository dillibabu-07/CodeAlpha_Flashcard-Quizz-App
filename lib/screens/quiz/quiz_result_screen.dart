// lib/screens/quiz/quiz_result_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../animations/confetti_overlay.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../providers/quiz_provider.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizProvider provider;

  const QuizResultScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final score = provider.score;
    final correct = provider.correctCount;
    final total = provider.totalQuestions;
    final duration = provider.durationSeconds;

    Color scoreColor;
    if (score >= 80) {
      scoreColor = AppColors.success;
    } else if (score >= 60) {
      scoreColor = AppColors.warning;
    } else {
      scoreColor = AppColors.error;
    }

    String message;
    if (score >= 90) {
      message = 'Excellent! 🏆';
    } else if (score >= 75) {
      message = 'Great Job! 🎯';
    } else if (score >= 60) {
      message = 'Good Work! 👍';
    } else if (score >= 40) {
      message = 'Keep Practicing! 💪';
    } else {
      message = 'Needs More Practice! 📚';
    }

    return ConfettiOverlay(
      trigger: score >= 60,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scoreColor,
                        scoreColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSizes.lg),
                        Text(
                          'Quiz Complete!',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        // Score circle
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 3),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${score.toStringAsFixed(0)}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Score',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          message,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white),
                onPressed: () =>
                    Navigator.popUntil(context, ModalRoute.withName('/home')),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  children: [
                    // Stats row
                    Row(
                      children: [
                        _ResultStat(
                          label: 'Correct',
                          value: '$correct',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        _ResultStat(
                          label: 'Wrong',
                          value: '${total - correct}',
                          icon: Icons.cancel_rounded,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        _ResultStat(
                          label: 'Duration',
                          value: _formatDuration(duration),
                          icon: Icons.timer_rounded,
                          color: AppColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Question breakdown
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLG),
                        border: Border.all(
                            color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppSizes.md),
                            child: Text('Question Breakdown',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                          ),
                          const Divider(height: 1),
                          ...provider.questions.asMap().entries.map((e) {
                            final q = e.value;
                            final isCorrect =
                                q.isAnswered && q.isCorrect;
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: isCorrect
                                    ? AppColors.success.withOpacity(0.15)
                                    : AppColors.error.withOpacity(0.15),
                                child: Text(
                                  '${e.key + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isCorrect
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                              title: Text(
                                q.flashcard.question,
                                style: GoogleFonts.inter(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                q.isAnswered
                                    ? (isCorrect
                                        ? 'Correct ✓'
                                        : 'Wrong — ${q.correctAnswer}')
                                    : 'Unanswered',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isCorrect
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Icon(
                                isCorrect
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: isCorrect
                                    ? AppColors.success
                                    : AppColors.error,
                                size: 18,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: provider.restartQuiz,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Retake Quiz'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.popUntil(
                            context, ModalRoute.withName('/home')),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Back to Home'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSizes.xxl)),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ResultStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
