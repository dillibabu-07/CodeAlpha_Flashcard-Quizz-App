// lib/screens/favorites/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_sizes.dart';
import '../../providers/category_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/flashcard/flashcard_tile.dart';
import '../../widgets/common/gradient_header.dart';
import '../flashcards/add_edit_flashcard_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final favorites = provider.favorites;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GradientHeader(
              colors: const [Color(0xFFDB2777), Color(0xFFBE185D)],
              child: Stack(
                children: [
                  Positioned.fill(child: const HeaderDecoration()),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.lg,
                      MediaQuery.of(context).padding.top + AppSizes.lg,
                      AppSizes.lg,
                      AppSizes.xxl,
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Favorites',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${favorites.length} bookmarked card${favorites.length != 1 ? 's' : ''}',
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.favorite_rounded,
                            color: Colors.white, size: 36),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          favorites.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: 'No Favorites Yet',
                    description:
                        'Tap the heart icon on any flashcard to bookmark it here',
                    iconColor: const Color(0xFFDB2777),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final card = favorites[i];
                      return FlashcardTile(
                        card: card,
                        accentColor: const Color(0xFFDB2777),
                        onFavorite: () => provider.toggleFavorite(card.id),
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  AddEditFlashcardScreen(card: card)),
                        ),
                        onDelete: () async {
                          await provider.deleteFlashcard(card.id);
                          if (context.mounted) {
                            CustomSnackbar.success(context, 'Card deleted');
                          }
                        },
                      );
                    },
                    childCount: favorites.length,
                  ),
                ),

          const SliverPadding(
              padding: EdgeInsets.only(bottom: AppSizes.xxl + AppSizes.lg)),
        ],
      ),
    );
  }
}
