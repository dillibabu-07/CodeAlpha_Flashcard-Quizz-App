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
  Future<List<FlashcardModel>> getAll({String? userId, SortOrder sort = SortOrder.newest}) async {
    final db = await _db;
    final orderBy = _sortOrderClause(sort);
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name,
             (SELECT COUNT(*) FROM user_favorites uf WHERE uf.flashcard_id = f.id AND uf.user_id = ?) AS is_favorite
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      ORDER BY $orderBy
    ''', [userId ?? '']);
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Get flashcards by category
  Future<List<FlashcardModel>> getByCategory(String categoryId,
      {String? userId, SortOrder sort = SortOrder.newest}) async {
    final db = await _db;
    final orderBy = _sortOrderClause(sort);
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name,
             (SELECT COUNT(*) FROM user_favorites uf WHERE uf.flashcard_id = f.id AND uf.user_id = ?) AS is_favorite
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      WHERE f.category_id = ?
      ORDER BY $orderBy
    ''', [userId ?? '', categoryId]);
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Get favorites for a specific user
  Future<List<FlashcardModel>> getFavorites(String userId) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name, 1 AS is_favorite
      FROM flashcards f
      INNER JOIN user_favorites uf ON uf.flashcard_id = f.id
      LEFT JOIN categories c ON f.category_id = c.id
      WHERE uf.user_id = ?
      ORDER BY f.updated_at DESC
    ''', [userId]);
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Search flashcards (question, answer, tags, category name)
  Future<List<FlashcardModel>> search(String query, {String? userId}) async {
    final db = await _db;
    final q = '%${query.toLowerCase()}%';
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name,
             (SELECT COUNT(*) FROM user_favorites uf WHERE uf.flashcard_id = f.id AND uf.user_id = ?) AS is_favorite
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      WHERE LOWER(f.question) LIKE ?
         OR LOWER(f.answer) LIKE ?
         OR LOWER(f.tags) LIKE ?
         OR LOWER(c.name) LIKE ?
      ORDER BY f.updated_at DESC
    ''', [userId ?? '', q, q, q, q]);
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Filter by difficulty
  Future<List<FlashcardModel>> getByDifficulty(String difficulty, {String? userId}) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name,
             (SELECT COUNT(*) FROM user_favorites uf WHERE uf.flashcard_id = f.id AND uf.user_id = ?) AS is_favorite
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      WHERE f.difficulty = ?
      ORDER BY f.updated_at DESC
    ''', [userId ?? '', difficulty]);
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Get recent flashcards (limit N)
  Future<List<FlashcardModel>> getRecent({String? userId, int limit = 10}) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name,
             (SELECT COUNT(*) FROM user_favorites uf WHERE uf.flashcard_id = f.id AND uf.user_id = ?) AS is_favorite
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      ORDER BY f.created_at DESC
      LIMIT ?
    ''', [userId ?? '', limit]);
    return results.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  /// Toggle favorite for a user
  Future<void> toggleFavorite(String id, String userId, bool isFavorite) async {
    final db = await _db;
    if (isFavorite) {
      await db.insert(
        'user_favorites',
        {
          'user_id': userId,
          'flashcard_id': id,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      await db.delete(
        'user_favorites',
        where: 'user_id = ? AND flashcard_id = ?',
        whereArgs: [userId, id],
      );
    }
  }

  /// Get total count
  Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) AS cnt FROM flashcards');
    return result.first['cnt'] as int;
  }

  /// Get single flashcard by ID
  Future<FlashcardModel?> getById(String id, {String? userId}) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT f.*, c.name AS category_name,
             (SELECT COUNT(*) FROM user_favorites uf WHERE uf.flashcard_id = f.id AND uf.user_id = ?) AS is_favorite
      FROM flashcards f
      LEFT JOIN categories c ON f.category_id = c.id
      WHERE f.id = ?
    ''', [userId ?? '', id]);
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
