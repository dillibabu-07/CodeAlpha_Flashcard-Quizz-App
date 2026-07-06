// lib/screens/study/study_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../providers/category_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/study_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/flashcard/flip_card.dart';
import '../flashcards/add_edit_flashcard_screen.dart';

class StudyScreen extends StatefulWidget {
  final String? categoryId;

  const StudyScreen({super.key, this.categoryId});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyProvider>().loadCards(categoryId: widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudyProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final cardProvider = context.watch<FlashcardProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Mode')),
        body: EmptyState(
          icon: Icons.style_outlined,
          title: 'No Flashcards',
          description: 'Add some flashcards to start studying!',
          buttonLabel: 'Add Flashcard',
          onButtonPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddEditFlashcardScreen(
                    preselectedCategoryId: widget.categoryId)),
          ),
        ),
      );
    }

    if (provider.isComplete) {
      return _SessionCompleteView(provider: provider);
    }

    final card = provider.currentCard!;
    final cat = catProvider.getById(card.categoryId);
    final catColor = cat?.color ?? AppColors.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          cat?.name ?? 'Study Mode',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          // Shuffle
          IconButton(
            icon: Icon(
              Icons.shuffle_rounded,
              color: provider.isShuffled ? AppColors.accent : null,
            ),
            onPressed: provider.shuffleCards,
            tooltip: 'Shuffle',
          ),
          // Restart
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: provider.restart,
            tooltip: 'Restart',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: provider.totalCards == 0
                  ? 0
                  : (provider.currentIndex + 1) / provider.totalCards,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          // Card counter
          Text(
            'Card ${provider.currentIndex + 1} of ${provider.totalCards}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
              fontWeight: FontWeight.w500,
            ),
          ),

          // FlipCard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < -300) {
                    provider.nextCard();
                  } else if (details.primaryVelocity! > 300) {
                    provider.previousCard();
                  }
                },
                child: FlipCard(
                  isFlipped: provider.isFlipped,
                  onFlip: provider.flipCard,
                  front: FlashcardFront(
                    question: card.question,
                    categoryName: cat?.name ?? '',
                    categoryColor: catColor,
                  ),
                  back: FlashcardBack(
                    answer: card.answer,
                    accentColor: catColor,
                  ),
                ),
              ),
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
            child: Column(
              children: [
                // Flip / hide
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: provider.flipCard,
                    icon: Icon(provider.isFlipped
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded),
                    label: Text(
                        provider.isFlipped ? 'Hide Answer' : 'Show Answer'),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                // Navigation row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            provider.hasPrevious ? provider.previousCard : null,
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            size: 16),
                        label: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    // Favorite
                    IconButton(
                      onPressed: provider.toggleFavorite,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          card.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(card.isFavorite),
                          color: card.isFavorite
                              ? Colors.red
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.nextCard,
                        icon: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 16),
                        label: Text(provider.hasNext ? 'Next' : 'Finish'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: provider.hasNext
                              ? AppColors.primary
                              : AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                // Swipe hint
                const SizedBox(height: AppSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swipe_rounded,
                        size: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.35)),
                    const SizedBox(width: 4),
                    Text(
                      'Swipe left/right to navigate',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.35),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCompleteView extends StatelessWidget {
  final StudyProvider provider;
  const _SessionCompleteView({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.celebration_rounded,
                    size: 52, color: Colors.white),
              ),
              const SizedBox(height: AppSizes.xl),
              Text(
                'Session Complete! 🎉',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                "You've studied ${provider.totalCards} flashcard${provider.totalCards != 1 ? 's' : ''}",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.restart,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Study Again'),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, '/quiz'),
                  icon: const Icon(Icons.quiz_rounded),
                  label: const Text('Take Quiz'),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              TextButton(
                onPressed: () => Navigator.popUntil(
                    context, ModalRoute.withName('/home')),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
