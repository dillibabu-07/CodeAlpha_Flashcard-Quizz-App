// lib/database/study_history_dao.dart
import 'package:sqflite/sqflite.dart';
import '../models/study_history_model.dart';
import 'database_helper.dart';

class StudyHistoryDao {
  static final StudyHistoryDao instance = StudyHistoryDao._internal();
  StudyHistoryDao._internal();

  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<void> insert(StudyHistoryModel entry) async {
    final db = await _db;
    await db.insert('study_history', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Cards studied today
  Future<int> getTodayCount() async {
    final db = await _db;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59)
        .toIso8601String();
    final result = await db.rawQuery('''
      SELECT COUNT(*) AS cnt FROM study_history
      WHERE studied_at BETWEEN ? AND ?
    ''', [start, end]);
    return result.first['cnt'] as int;
  }

  /// Total cards ever studied
  Future<int> getTotalCount() async {
    final db = await _db;
    final result =
        await db.rawQuery('SELECT COUNT(*) AS cnt FROM study_history');
    return result.first['cnt'] as int;
  }

  /// Daily study counts for the past N days (for bar chart)
  Future<List<DailyStudyStat>> getDailyStats({int days = 7}) async {
    final db = await _db;
    final stats = <DailyStudyStat>[];
    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final start = DateTime(date.year, date.month, date.day).toIso8601String();
      final end =
          DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();
      final result = await db.rawQuery('''
        SELECT COUNT(*) AS total, SUM(was_correct) AS correct
        FROM study_history
        WHERE studied_at BETWEEN ? AND ?
      ''', [start, end]);
      final total = result.first['total'] as int;
      final correct = (result.first['correct'] as int?) ?? 0;
      stats.add(DailyStudyStat(
        date: date,
        cardsStudied: total,
        correctAnswers: correct,
      ));
    }
    return stats;
  }

  /// Current study streak (consecutive days with at least 1 card studied)
  Future<int> getStudyStreak() async {
    final db = await _db;
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final start = DateTime(date.year, date.month, date.day).toIso8601String();
      final end =
          DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();
      final result = await db.rawQuery('''
        SELECT COUNT(*) AS cnt FROM study_history
        WHERE studied_at BETWEEN ? AND ?
      ''', [start, end]);
      final count = result.first['cnt'] as int;
      if (count > 0) {
        streak++;
      } else if (i > 0) {
        break; // streak broken
      }
    }
    return streak;
  }

  /// Batch insert
  Future<void> insertAll(List<StudyHistoryModel> entries) async {
    final db = await _db;
    final batch = db.batch();
    for (final e in entries) {
      batch.insert('study_history', e.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }
}
