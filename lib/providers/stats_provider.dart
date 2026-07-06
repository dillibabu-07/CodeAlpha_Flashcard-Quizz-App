// lib/providers/stats_provider.dart
import 'package:flutter/foundation.dart';
import '../database/study_history_dao.dart';
import '../database/quiz_result_dao.dart';
import '../database/flashcard_dao.dart';
import '../database/category_dao.dart';
import '../models/quiz_result_model.dart';
import '../models/study_history_model.dart';

class StatsProvider extends ChangeNotifier {
  bool _isLoading = false;

  // Summary stats
  int _totalCards = 0;
  int _totalCategories = 0;
  int _totalStudied = 0;
  int _todayStudied = 0;
  int _studyStreak = 0;
  double _averageAccuracy = 0;
  double _bestScore = 0;
  int _totalSessions = 0;
  int _favoriteCount = 0;

  // Chart data
  List<DailyStudyStat> _weeklyStats = [];
  List<DailyStudyStat> _monthlyStats = [];
  List<QuizResultModel> _recentResults = [];

  // Getters
  bool get isLoading => _isLoading;
  int get totalCards => _totalCards;
  int get totalCategories => _totalCategories;
  int get totalStudied => _totalStudied;
  int get todayStudied => _todayStudied;
  int get studyStreak => _studyStreak;
  double get averageAccuracy => _averageAccuracy;
  double get bestScore => _bestScore;
  int get totalSessions => _totalSessions;
  int get favoriteCount => _favoriteCount;
  List<DailyStudyStat> get weeklyStats => _weeklyStats;
  List<DailyStudyStat> get monthlyStats => _monthlyStats;
  List<QuizResultModel> get recentResults => _recentResults;

  String? _lastUserId;
  String? _lastRole;

  /// Load all statistics
  Future<void> loadStats({String? userId, String? role}) async {
    if (userId != null) _lastUserId = userId;
    if (role != null) _lastRole = role;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadCounts(),
        _loadStudyStats(),
        _loadQuizStats(),
        _loadChartData(),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCounts() async {
    _totalCards = await FlashcardDao.instance.count();
    _totalCategories = await CategoryDao.instance.count();
    if (_lastUserId != null && _lastRole == 'Student') {
      _favoriteCount = (await FlashcardDao.instance.getFavorites(_lastUserId!)).length;
    } else {
      _favoriteCount = 0;
    }
  }

  Future<void> _loadStudyStats() async {
    final activeUserId = _lastRole == 'Student' ? _lastUserId : null;
    _totalStudied = await StudyHistoryDao.instance.getTotalCount(userId: activeUserId);
    _todayStudied = await StudyHistoryDao.instance.getTodayCount(userId: activeUserId);
    _studyStreak = await StudyHistoryDao.instance.getStudyStreak(userId: activeUserId);
  }

  Future<void> _loadQuizStats() async {
    final activeUserId = _lastRole == 'Student' ? _lastUserId : null;
    _averageAccuracy = await QuizResultDao.instance.getAverageAccuracy(userId: activeUserId);
    _bestScore = await QuizResultDao.instance.getBestScore(userId: activeUserId);
    _totalSessions = await QuizResultDao.instance.getTotalSessions(userId: activeUserId);
    _recentResults = await QuizResultDao.instance.getRecent(userId: activeUserId, limit: 5);
  }

  Future<void> _loadChartData() async {
    final activeUserId = _lastRole == 'Student' ? _lastUserId : null;
    _weeklyStats = await StudyHistoryDao.instance.getDailyStats(userId: activeUserId, days: 7);
    _monthlyStats = await StudyHistoryDao.instance.getDailyStats(userId: activeUserId, days: 30);
  }
}
