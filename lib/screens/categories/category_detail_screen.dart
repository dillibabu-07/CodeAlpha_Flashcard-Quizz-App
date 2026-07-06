// lib/screens/categories/category_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../models/category_model.dart';
import '../../providers/flashcard_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/flashcard/flashcard_tile.dart';
import '../flashcards/add_edit_flashcard_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final isAdmin = user?.role == 'Admin';
    final cards = provider.getByCategory(widget.category.id);
    final cat = widget.category;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.categoryGradients[
                        cat.name.hashCode.abs() %
                            AppColors.categoryGradients.length],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg, 48, AppSizes.lg, AppSizes.md),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMD),
                          ),
                          child: Icon(cat.icon, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cat.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${cards.length} flashcard${cards.length != 1 ? 's' : ''}',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: Text(
                cat.name,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              titlePadding:
                  const EdgeInsets.only(left: 60, bottom: 16),
            ),
            actions: [
              if (cards.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.play_arrow_rounded),
                  tooltip: 'Study',
                  onPressed: () => Navigator.pushNamed(context, '/study',
                      arguments: cat.id),
                ),
              if (cards.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.quiz_rounded),
                  tooltip: 'Quiz',
                  onPressed: () => Navigator.pushNamed(context, '/quiz',
                      arguments: cat.id),
                ),
            ],
          ),

          cards.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.style_rounded,
                    title: 'No Flashcards',
                    description: isAdmin
                        ? 'Add flashcards to this category to start studying'
                        : 'No flashcards available in this category yet.',
                    buttonLabel: isAdmin ? 'Add Flashcard' : null,
                    iconColor: cat.color,
                    onButtonPressed: isAdmin ? () => _addCard(context, provider) : null,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final card = cards[i];
                      return FlashcardTile(
                        card: card,
                        accentColor: cat.color,
                        onFavorite: () => provider.toggleFavorite(card.id, userId: user?.id),
                        onEdit: isAdmin
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddEditFlashcardScreen(card: card),
                                  ),
                                )
                            : null,
                        onDelete: isAdmin
                            ? () async {
                                await provider.deleteFlashcard(card.id);
                                if (context.mounted) {
                                  CustomSnackbar.success(context, 'Card deleted');
                                }
                              }
                            : null,
                        onDuplicate: isAdmin
                            ? () async {
                                final dup = card.copyWith(
                                  id: null,
                                  question: '${card.question} (copy)',
                                );
                                await provider.addFlashcard(dup);
                                if (context.mounted) {
                                  CustomSnackbar.success(context, 'Card duplicated');
                                }
                              }
                            : null,
                      );
                    },
                    childCount: cards.length,
                  ),
                ),

          const SliverPadding(
              padding: EdgeInsets.only(bottom: AppSizes.xxl + AppSizes.lg)),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _addCard(context, provider),
              child: const Icon(Icons.add_rounded),
              tooltip: 'Add Flashcard',
            )
          : null,
    );
  }

  void _addCard(BuildContext context, FlashcardProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddEditFlashcardScreen(preselectedCategoryId: widget.category.id),
      ),
    );
  }
}
