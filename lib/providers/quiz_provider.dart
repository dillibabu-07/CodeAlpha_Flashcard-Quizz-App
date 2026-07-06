// lib/providers/quiz_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/flashcard_model.dart';
import '../models/quiz_result_model.dart';
import '../database/flashcard_dao.dart';
import '../database/quiz_result_dao.dart';
import 'package:uuid/uuid.dart';

enum QuizState { idle, loading, active, reviewing, complete }

class QuizProvider extends ChangeNotifier {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  QuizState _state = QuizState.idle;
  String? _categoryId;

  // Timer
  int _timerSeconds = 30;
  int _remainingSeconds = 30;
  bool _timerEnabled = false;
  Timer? _timer;

  // Score tracking
  int _correctCount = 0;
  DateTime? _startTime;

  // Getters
  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  QuizState get state => _state;
  int get totalQuestions => _questions.length;
  int get correctCount => _correctCount;
  int get timerSeconds => _timerSeconds;
  int get remainingSeconds => _remainingSeconds;
  bool get timerEnabled => _timerEnabled;
  bool get isComplete => _state == QuizState.complete;

  QuizQuestion? get currentQuestion {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return null;
    return _questions[_currentIndex];
  }

  double get score => _questions.isEmpty
      ? 0
      : (_correctCount / _questions.length) * 100;

  int get durationSeconds =>
      _startTime == null ? 0 : DateTime.now().difference(_startTime!).inSeconds;

  /// Load and generate quiz
  Future<void> loadQuiz({
    String? categoryId,
    int questionCount = 10,
    bool enableTimer = false,
    int timerSecs = 30,
  }) async {
    _cancelTimer();
    _state = QuizState.loading;
    _categoryId = categoryId;
    _timerEnabled = enableTimer;
    _timerSeconds = timerSecs;
    _currentIndex = 0;
    _correctCount = 0;
    _questions = [];
    notifyListeners();

    try {
      List<FlashcardModel> cards;
      if (categoryId != null) {
        cards = await FlashcardDao.instance.getByCategory(categoryId);
      } else {
        cards = await FlashcardDao.instance.getAll();
      }

      if (cards.length < 2) {
        _state = QuizState.idle;
        notifyListeners();
        return;
      }

      // Shuffle and limit
      cards.shuffle(Random());
      final selected = cards.take(min(questionCount, cards.length)).toList();

      // Build questions with 4 options each
      _questions = selected.map((card) {
        final distractors = _pickDistractors(card, cards, 3);
        final allOptions = [card.answer, ...distractors]..shuffle(Random());
        return QuizQuestion(
          flashcard: FlashcardRef(
            id: card.id,
            question: card.question,
            answer: card.answer,
          ),
          correctAnswer: card.answer,
          options: allOptions,
        );
      }).toList();

      _startTime = DateTime.now();
      _state = QuizState.active;
      if (_timerEnabled) _startTimer();
    } catch (e) {
      _state = QuizState.idle;
    }
    notifyListeners();
  }

  /// Answer current question
  void answerQuestion(int optionIndex) {
    final q = currentQuestion;
    if (q == null || q.isAnswered) return;
    _cancelTimer();
    q.selectedOptionIndex = optionIndex;
    if (q.isCorrect) _correctCount++;
    _state = QuizState.reviewing;
    notifyListeners();
  }

  /// Move to next question
  Future<void> nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _state = QuizState.active;
      if (_timerEnabled) _startTimer();
    } else {
      await _finishQuiz();
    }
    notifyListeners();
  }

  /// Save result and mark complete
  Future<void> _finishQuiz() async {
    _state = QuizState.complete;
    final result = QuizResultModel(
      id: const Uuid().v4(),
      categoryId: _categoryId ?? 'all',
      score: _correctCount,
      total: _questions.length,
      percentage: score,
      durationSeconds: durationSeconds,
      createdAt: DateTime.now(),
    );
    await QuizResultDao.instance.insert(result);
  }

  /// Restart quiz with same settings
  Future<void> restartQuiz() async {
    await loadQuiz(
      categoryId: _categoryId,
      questionCount: _questions.length,
      enableTimer: _timerEnabled,
      timerSecs: _timerSeconds,
    );
  }

  void _startTimer() {
    _remainingSeconds = _timerSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        _cancelTimer();
        // Auto-answer as wrong
        answerQuestion(-1);
      } else {
        _remainingSeconds--;
        notifyListeners();
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = _timerSeconds;
  }

  List<String> _pickDistractors(
      FlashcardModel correct, List<FlashcardModel> all, int count) {
    final pool = all
        .where((c) => c.id != correct.id)
        .map((c) => c.answer)
        .toSet()
        .toList()
      ..shuffle(Random());
    return pool.take(count).toList();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
