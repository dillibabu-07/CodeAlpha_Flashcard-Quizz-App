// lib/screens/flashcards/flashcards_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../database/flashcard_dao.dart';
import '../../providers/category_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/flashcard/flashcard_tile.dart';
import 'add_edit_flashcard_screen.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final cards = provider.filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        actions: [
          // Sort button
          PopupMenuButton<SortOrder>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort',
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD)),
            initialValue: provider.sortOrder,
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: SortOrder.newest,
                  child: Text('Newest First')),
              const PopupMenuItem(
                  value: SortOrder.oldest,
                  child: Text('Oldest First')),
              const PopupMenuItem(
                  value: SortOrder.alphabetical,
                  child: Text('Alphabetical')),
              const PopupMenuItem(
                  value: SortOrder.difficulty,
                  child: Text('By Difficulty')),
            ],
            onSelected: provider.setSortOrder,
          ),
          // Filter button
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list_rounded),
                if (provider.filterCategoryId != null ||
                    provider.filterDifficulty != null ||
                    provider.filterFavorites)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showFilterSheet(context, provider, catProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.md, 0, AppSizes.md, AppSizes.sm),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search flashcards...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: cards.isEmpty
          ? EmptyState(
              icon: Icons.style_outlined,
              title: provider.searchQuery.isNotEmpty
                  ? 'No Results Found'
                  : 'No Flashcards Yet',
              description: provider.searchQuery.isNotEmpty
                  ? 'Try different keywords or clear filters'
                  : 'Add your first flashcard to start studying',
              buttonLabel: provider.searchQuery.isEmpty ? 'Add Flashcard' : null,
              onButtonPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddEditFlashcardScreen()),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                  top: AppSizes.sm, bottom: AppSizes.xxl + AppSizes.lg),
              itemCount: cards.length,
              itemBuilder: (_, i) {
                final card = cards[i];
                return Dismissible(
                  key: Key(card.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding:
                        const EdgeInsets.only(right: AppSizes.lg),
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md, vertical: AppSizes.xs),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusLG),
                    ),
                    child: const Icon(Icons.delete_rounded,
                        color: AppColors.error),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Card'),
                        content: const Text(
                            'Are you sure you want to delete this flashcard?'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    await provider.deleteFlashcard(card.id);
                    if (context.mounted) {
                      CustomSnackbar.success(context, 'Flashcard deleted');
                    }
                  },
                  child: FlashcardTile(
                    card: card,
                    accentColor:
                        catProvider.getById(card.categoryId)?.color,
                    onFavorite: () =>
                        provider.toggleFavorite(card.id),
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AddEditFlashcardScreen(card: card)),
                    ),
                    onDelete: () async {
                      await provider.deleteFlashcard(card.id);
                      if (context.mounted) {
                        CustomSnackbar.success(
                            context, 'Flashcard deleted');
                      }
                    },
                    onDuplicate: () async {
                      final dup = card.copyWith(
                        id: null,
                        question: '${card.question} (copy)',
                      );
                      await provider.addFlashcard(dup);
                      if (context.mounted) {
                        CustomSnackbar.success(
                            context, 'Card duplicated');
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddEditFlashcardScreen()),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, FlashcardProvider provider,
      CategoryProvider catProvider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _FilterSheet(
          provider: provider, catProvider: catProvider),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final FlashcardProvider provider;
  final CategoryProvider catProvider;

  const _FilterSheet(
      {required this.provider, required this.catProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Text('Filters',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  provider.clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: AppSizes.sm),
          Text('Difficulty',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.xs),
          Wrap(
            spacing: 8,
            children: ['easy', 'medium', 'hard'].map((d) {
              final selected = provider.filterDifficulty == d;
              return FilterChip(
                label: Text(d.substring(0, 1).toUpperCase() + d.substring(1)),
                selected: selected,
                onSelected: (_) {
                  provider.setDifficultyFilter(selected ? null : d);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.md),
          Text('Other',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          CheckboxListTile(
            title: const Text('Favorites only'),
            value: provider.filterFavorites,
            onChanged: (v) => provider.setFavoritesFilter(v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
