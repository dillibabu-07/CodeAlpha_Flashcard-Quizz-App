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

  /// Load all statistics
  Future<void> loadStats() async {
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
    _favoriteCount = (await FlashcardDao.instance.getFavorites()).length;
  }

  Future<void> _loadStudyStats() async {
    _totalStudied = await StudyHistoryDao.instance.getTotalCount();
    _todayStudied = await StudyHistoryDao.instance.getTodayCount();
    _studyStreak = await StudyHistoryDao.instance.getStudyStreak();
  }

  Future<void> _loadQuizStats() async {
    _averageAccuracy = await QuizResultDao.instance.getAverageAccuracy();
    _bestScore = await QuizResultDao.instance.getBestScore();
    _totalSessions = await QuizResultDao.instance.getTotalSessions();
    _recentResults = await QuizResultDao.instance.getRecent(limit: 5);
  }

  Future<void> _loadChartData() async {
    _weeklyStats = await StudyHistoryDao.instance.getDailyStats(days: 7);
    _monthlyStats = await StudyHistoryDao.instance.getDailyStats(days: 30);
  }
}
