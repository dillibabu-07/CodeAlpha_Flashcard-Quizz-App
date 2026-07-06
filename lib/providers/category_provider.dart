// lib/providers/category_provider.dart
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../database/category_dao.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _categories.length;

  /// Load all categories from DB
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await CategoryDao.instance.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new category
  Future<void> addCategory(CategoryModel category) async {
    await CategoryDao.instance.insert(category);
    await loadCategories();
  }

  /// Update an existing category
  Future<void> updateCategory(CategoryModel category) async {
    await CategoryDao.instance.update(category);
    final idx = _categories.indexWhere((c) => c.id == category.id);
    if (idx != -1) {
      _categories[idx] = category;
      notifyListeners();
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String id) async {
    await CategoryDao.instance.delete(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  /// Get category by ID (from cache)
  CategoryModel? getById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Reload card counts
  Future<void> refreshCounts() async {
    await loadCategories();
  }
}
