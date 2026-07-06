// lib/database/category_dao.dart
import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import 'database_helper.dart';

class CategoryDao {
  static final CategoryDao instance = CategoryDao._internal();
  CategoryDao._internal();

  Future<Database> get _db => DatabaseHelper.instance.database;

  /// Insert a new category
  Future<void> insert(CategoryModel category) async {
    final db = await _db;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing category
  Future<void> update(CategoryModel category) async {
    final db = await _db;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Delete a category (cascades to flashcards)
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  /// Get all categories with card counts
  Future<List<CategoryModel>> getAll() async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT c.*, COUNT(f.id) AS card_count
      FROM categories c
      LEFT JOIN flashcards f ON f.category_id = c.id
      GROUP BY c.id
      ORDER BY c.created_at ASC
    ''');
    return results.map((m) => CategoryModel.fromMap(m)).toList();
  }

  /// Get a single category by ID
  Future<CategoryModel?> getById(String id) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT c.*, COUNT(f.id) AS card_count
      FROM categories c
      LEFT JOIN flashcards f ON f.category_id = c.id
      WHERE c.id = ?
      GROUP BY c.id
    ''', [id]);
    if (results.isEmpty) return null;
    return CategoryModel.fromMap(results.first);
  }

  /// Get total category count
  Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) AS cnt FROM categories');
    return result.first['cnt'] as int;
  }

  /// Batch insert (for sample data / import)
  Future<void> insertAll(List<CategoryModel> categories) async {
    final db = await _db;
    final batch = db.batch();
    for (final c in categories) {
      batch.insert('categories', c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }
}
