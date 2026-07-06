// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../providers/category_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../widgets/flashcard/flashcard_tile.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../flashcards/add_edit_flashcard_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<String> _recentSearches = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recent_searches') ?? [];
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 10) searches.removeLast();
    await prefs.setStringList('recent_searches', searches);
    setState(() => _recentSearches = searches);
  }

  @override
  void dispose() {
    // Clear search when leaving
    context.read<FlashcardProvider>().setSearchQuery('');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final results = provider.searchQuery.isNotEmpty ? provider.filtered : [];

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search flashcards...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          style: GoogleFonts.inter(fontSize: 16),
          onChanged: (q) {
            setState(() => _hasSearched = q.isNotEmpty);
            provider.setSearchQuery(q);
          },
          onSubmitted: (q) => _saveSearch(q),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _controller.clear();
                provider.setSearchQuery('');
                setState(() => _hasSearched = false);
              },
            ),
        ],
      ),
      body: !_hasSearched
          // Recent searches
          ? _recentSearches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_rounded,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.2)),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'Search for flashcards',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                      Text(
                        'by question, answer, category, or tag',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs),
                      child: Row(
                        children: [
                          Text('Recent Searches',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('recent_searches');
                              setState(() => _recentSearches = []);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                    ..._recentSearches.map((s) => ListTile(
                          leading: const Icon(Icons.history_rounded, size: 18),
                          title: Text(s, style: GoogleFonts.inter(fontSize: 14)),
                          trailing: const Icon(
                              Icons.north_west_rounded,
                              size: 16),
                          onTap: () {
                            _controller.text = s;
                            provider.setSearchQuery(s);
                            setState(() => _hasSearched = true);
                          },
                          onLongPress: () {
                            setState(() => _recentSearches.remove(s));
                          },
                        )),
                  ],
                )
          // Search results
          : results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 64, color: AppColors.lightTextHint),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'No results for "${_controller.text}"',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        'Try different keywords',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSizes.md, AppSizes.sm, AppSizes.md, 0),
                      child: Row(
                        children: [
                          Text(
                            '${results.length} result${results.length != 1 ? 's' : ''}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                            top: AppSizes.xs, bottom: AppSizes.xl),
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          final card = results[i];
                          return FlashcardTile(
                            card: card,
                            accentColor:
                                catProvider.getById(card.categoryId)?.color,
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
                      ),
                    ),
                  ],
                ),
    );
  }
}
