// lib/database/quiz_result_dao.dart
import 'package:sqflite/sqflite.dart';
import '../models/quiz_result_model.dart';
import 'database_helper.dart';

class QuizResultDao {
  static final QuizResultDao instance = QuizResultDao._internal();
  QuizResultDao._internal();

  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<void> insert(QuizResultModel result) async {
    final db = await _db;
    await db.insert('quiz_results', result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<QuizResultModel>> getAll({String? userId}) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT qr.*, c.name AS category_name
      FROM quiz_results qr
      LEFT JOIN categories c ON qr.category_id = c.id
      ${userId != null ? 'WHERE qr.user_id = ?' : ''}
      ORDER BY qr.created_at DESC
    ''', userId != null ? [userId] : []);
    return results.map((m) => QuizResultModel.fromMap(m)).toList();
  }

  Future<List<QuizResultModel>> getRecent({String? userId, int limit = 5}) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT qr.*, c.name AS category_name
      FROM quiz_results qr
      LEFT JOIN categories c ON qr.category_id = c.id
      ${userId != null ? 'WHERE qr.user_id = ?' : ''}
      ORDER BY qr.created_at DESC
      LIMIT ?
    ''', userId != null ? [userId, limit] : [limit]);
    return results.map((m) => QuizResultModel.fromMap(m)).toList();
  }

  Future<double> getAverageAccuracy({String? userId}) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT AVG(percentage) AS avg FROM quiz_results' +
      (userId != null ? ' WHERE user_id = ?' : ''),
      userId != null ? [userId] : [],
    );
    return (result.first['avg'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getBestScore({String? userId}) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT MAX(percentage) AS best FROM quiz_results' +
      (userId != null ? ' WHERE user_id = ?' : ''),
      userId != null ? [userId] : [],
    );
    return (result.first['best'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTotalSessions({String? userId}) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM quiz_results' +
      (userId != null ? ' WHERE user_id = ?' : ''),
      userId != null ? [userId] : [],
    );
    return result.first['cnt'] as int;
  }
}

// lib/database/study_history_dao.dart
