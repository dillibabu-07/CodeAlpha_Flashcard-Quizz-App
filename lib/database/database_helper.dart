// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'flashmaster.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_hex TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Flashcards table
    await db.execute('''
      CREATE TABLE flashcards (
        id TEXT PRIMARY KEY,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        category_id TEXT NOT NULL,
        difficulty TEXT NOT NULL DEFAULT 'medium',
        tags TEXT NOT NULL DEFAULT '',
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // Quiz results table
    await db.execute('''
      CREATE TABLE quiz_results (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        score INTEGER NOT NULL,
        total INTEGER NOT NULL,
        percentage REAL NOT NULL,
        duration_seconds INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // Study history table
    await db.execute('''
      CREATE TABLE study_history (
        id TEXT PRIMARY KEY,
        flashcard_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        was_correct INTEGER NOT NULL DEFAULT 0,
        studied_at TEXT NOT NULL,
        FOREIGN KEY (flashcard_id) REFERENCES flashcards(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // Indexes for performance
    await db.execute('CREATE INDEX idx_flashcards_category ON flashcards(category_id)');
    await db.execute('CREATE INDEX idx_flashcards_favorite ON flashcards(is_favorite)');
    await db.execute('CREATE INDEX idx_study_history_date ON study_history(studied_at)');
    await db.execute('CREATE INDEX idx_quiz_results_date ON quiz_results(created_at)');

    // Settings table for first-run flag
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migration logic here
  }

  /// Check if sample data was already seeded
  Future<bool> isFirstRun() async {
    final db = await database;
    final result = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: ['seeded'],
    );
    return result.isEmpty;
  }

  /// Mark app as seeded (not first run)
  Future<void> markSeeded() async {
    final db = await database;
    await db.insert('app_settings', {'key': 'seeded', 'value': 'true'},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Drop all data (reset)
  Future<void> resetAllData() async {
    final db = await database;
    await db.delete('study_history');
    await db.delete('quiz_results');
    await db.delete('flashcards');
    await db.delete('categories');
    await db.delete('app_settings');
  }

  /// Close the database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
