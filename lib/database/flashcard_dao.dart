// lib/database/flashcard_dao.dart
import 'package:sqflite/sqflite.dart';
import '../models/flashcard_model.dart';
import 'database_helper.dart';

enum SortOrder { newest, oldest, alphabetical, difficulty }

class FlashcardDao {
  static final FlashcardDao instance = FlashcardDao._internal();
  FlashcardDao._internal();

  Future<Database> get _db => DatabaseHelper.instance.database;

  /// Insert a new flashcard
  Future<void> insert(FlashcardModel card) async {
    final db = await _db;
    await db.insert(
      'flashcards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing flashcard
  Future<void> update(FlashcardModel card) async {
    final db = await _db;
    await db.update(
      'flashcards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  /// Delete a flashcard
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }

  /// Get all flashcards with category name (joined)
  Future<List<FlashcardModel>> getAll({SortOrder sort = SortOrder.newest}) async {
    final db = await _db;
    final orderBy = _sortOrderClause(sort);
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      ORDER BY $orderBy
    ''');
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Get flashcards by category
  Future<List<FlashcardModel>> getByCategory(String categoryId,
      {SortOrder sort = SortOrder.newest}) async {
    final db = await _db;
    final orderBy = _sortOrderClause(sort);
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      WHERE f.category_id = ?
      ORDER BY $orderBy
    ''', [categoryId]);
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Get favorites
  Future<List<FlashcardModel>> getFavorites() async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      WHERE f.is_favorite = 1
      ORDER BY f.updated_at DESC
    ''');
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Search flashcards (question, answer, tags, category name)
  Future<List<FlashcardModel>> search(String query) async {
    final db = await _db;
    final q = '%${query.toLowerCase()}%';
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      WHERE LOWER(f.question) LIKE ?
         OR LOWER(f.answer) LIKE ?
         OR LOWER(f.tags) LIKE ?
         OR LOWER(c.name) LIKE ?
      ORDER BY f.updated_at DESC
    ''', [q, q, q, q]);
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Filter by difficulty
  Future<List<FlashcardModel>> getByDifficulty(String difficulty) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      WHERE f.difficulty = ?
      ORDER BY f.updated_at DESC
    ''', [difficulty]);
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Get recent flashcards (limit N)
  Future<List<FlashcardModel>> getRecent({int limit = 10}) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      ORDER BY f.created_at DESC
      LIMIT ?
    ''', [limit]);
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await _db;
    await db.update(
      'flashcards',
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get total count
  Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) AS cnt FROM flashcards');
    return result.first['cnt'] as int;
  }

  /// Get single flashcard by ID
  Future<FlashcardModel?> getById(String id) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      WHERE f.id = ?
    ''', [id]);
    if (results.isEmpty) return null;
    return FlashcardModel.fromMap(results.first);
  }

  /// Batch insert (for sample data / import)
  Future<void> insertAll(List<FlashcardModel> cards) async {
    final db = await _db;
    final batch = db.batch();
    for (final c in cards) {
      batch.insert('flashcards', c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  String _sortOrderClause(SortOrder sort) {
    switch (sort) {
      case SortOrder.newest:
        return 'f.created_at DESC';
      case SortOrder.oldest:
        return 'f.created_at ASC';
      case SortOrder.alphabetical:
        return 'f.question ASC';
      case SortOrder.difficulty:
        return "CASE f.difficulty WHEN 'easy' THEN 1 WHEN 'medium' THEN 2 WHEN 'hard' THEN 3 END ASC";
    }
  }
}
