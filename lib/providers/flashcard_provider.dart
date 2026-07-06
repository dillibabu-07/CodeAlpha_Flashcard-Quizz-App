// lib/providers/flashcard_provider.dart
import 'package:flutter/foundation.dart';
import '../models/flashcard_model.dart';
import '../database/flashcard_dao.dart';

class FlashcardProvider extends ChangeNotifier {
  List<FlashcardModel> _all = [];
  List<FlashcardModel> _filtered = [];
  List<FlashcardModel> _favorites = [];
  List<FlashcardModel> _recent = [];

  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _filterCategoryId;
  String? _filterDifficulty;
  bool _filterFavorites = false;
  SortOrder _sortOrder = SortOrder.newest;

  // Getters
  List<FlashcardModel> get all => List.unmodifiable(_all);
  List<FlashcardModel> get filtered => List.unmodifiable(_filtered);
  List<FlashcardModel> get favorites => List.unmodifiable(_favorites);
  List<FlashcardModel> get recent => List.unmodifiable(_recent);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get filterCategoryId => _filterCategoryId;
  String? get filterDifficulty => _filterDifficulty;
  bool get filterFavorites => _filterFavorites;
  SortOrder get sortOrder => _sortOrder;
  int get totalCount => _all.length;
  int get favoriteCount => _favorites.length;

  /// Load all flashcards from DB
  Future<void> loadFlashcards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _all = await FlashcardDao.instance.getAll(sort: _sortOrder);
      _favorites = await FlashcardDao.instance.getFavorites();
      _recent = await FlashcardDao.instance.getRecent(limit: 8);
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add flashcard
  Future<void> addFlashcard(FlashcardModel card) async {
    await FlashcardDao.instance.insert(card);
    await loadFlashcards();
  }

  /// Update flashcard
  Future<void> updateFlashcard(FlashcardModel card) async {
    await FlashcardDao.instance.update(card);
    await loadFlashcards();
  }

  /// Delete flashcard
  Future<void> deleteFlashcard(String id) async {
    await FlashcardDao.instance.delete(id);
    _all.removeWhere((c) => c.id == id);
    _favorites.removeWhere((c) => c.id == id);
    _recent.removeWhere((c) => c.id == id);
    _applyFilters();
    notifyListeners();
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String id) async {
    final idx = _all.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    final card = _all[idx];
    final newFav = !card.isFavorite;
    await FlashcardDao.instance.toggleFavorite(id, newFav);
    _all[idx] = card.copyWith(isFavorite: newFav);
    _favorites = _all.where((c) => c.isFavorite).toList();
    _applyFilters();
    notifyListeners();
  }

  /// Get flashcards by category (from memory)
  List<FlashcardModel> getByCategory(String categoryId) {
    return _all.where((c) => c.categoryId == categoryId).toList();
  }

  /// Set search query and re-filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Set category filter
  void setCategoryFilter(String? categoryId) {
    _filterCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  /// Set difficulty filter
  void setDifficultyFilter(String? difficulty) {
    _filterDifficulty = difficulty;
    _applyFilters();
    notifyListeners();
  }

  /// Toggle favorites filter
  void setFavoritesFilter(bool value) {
    _filterFavorites = value;
    _applyFilters();
    notifyListeners();
  }

  /// Set sort order
  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    _sortAll();
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _filterCategoryId = null;
    _filterDifficulty = null;
    _filterFavorites = false;
    _sortOrder = SortOrder.newest;
    _applyFilters();
    notifyListeners();
  }

  void _sortAll() {
    switch (_sortOrder) {
      case SortOrder.newest:
        _all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOrder.oldest:
        _all.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOrder.alphabetical:
        _all.sort((a, b) => a.question.compareTo(b.question));
        break;
      case SortOrder.difficulty:
        const order = {Difficulty.easy: 1, Difficulty.medium: 2, Difficulty.hard: 3};
        _all.sort((a, b) => (order[a.difficulty] ?? 2).compareTo(order[b.difficulty] ?? 2));
        break;
    }
  }

  void _applyFilters() {
    var list = List<FlashcardModel>.from(_all);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) {
        return c.question.toLowerCase().contains(q) ||
            c.answer.toLowerCase().contains(q) ||
            c.tags.any((t) => t.toLowerCase().contains(q)) ||
            (c.categoryName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Category filter
    if (_filterCategoryId != null) {
      list = list.where((c) => c.categoryId == _filterCategoryId).toList();
    }

    // Difficulty filter
    if (_filterDifficulty != null) {
      list = list.where((c) => c.difficulty.value == _filterDifficulty).toList();
    }

    // Favorites filter
    if (_filterFavorites) {
      list = list.where((c) => c.isFavorite).toList();
    }

    _filtered = list;
  }
}
