// lib/providers/study_provider.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/flashcard_model.dart';
import '../models/study_history_model.dart';
import '../database/study_history_dao.dart';
import '../database/flashcard_dao.dart';
import 'package:uuid/uuid.dart';

class StudyProvider extends ChangeNotifier {
  List<FlashcardModel> _cards = [];
  List<FlashcardModel> _originalCards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isShuffled = false;
  bool _isComplete = false;
  bool _isLoading = false;
  String? _categoryId;

  // Getters
  List<FlashcardModel> get cards => _cards;
  int get currentIndex => _currentIndex;
  bool get isFlipped => _isFlipped;
  bool get isShuffled => _isShuffled;
  bool get isComplete => _isComplete;
  bool get isLoading => _isLoading;
  int get totalCards => _cards.length;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _cards.length - 1;

  FlashcardModel? get currentCard {
    if (_cards.isEmpty || _currentIndex >= _cards.length) return null;
    return _cards[_currentIndex];
  }

  /// Load cards for a category (or all if null)
  Future<void> loadCards({String? categoryId}) async {
    _isLoading = true;
    _currentIndex = 0;
    _isFlipped = false;
    _isShuffled = false;
    _isComplete = false;
    _categoryId = categoryId;
    notifyListeners();

    try {
      if (categoryId != null) {
        _cards = await FlashcardDao.instance.getByCategory(categoryId);
      } else {
        _cards = await FlashcardDao.instance.getAll();
      }
      _originalCards = List.from(_cards);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Flip the current card
  void flipCard() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  /// Move to next card
  Future<void> nextCard() async {
    if (!hasNext) {
      _isComplete = true;
      notifyListeners();
      return;
    }
    await _recordStudy();
    _currentIndex++;
    _isFlipped = false;
    notifyListeners();
  }

  /// Move to previous card
  void previousCard() {
    if (!hasPrevious) return;
    _currentIndex--;
    _isFlipped = false;
    notifyListeners();
  }

  /// Shuffle cards
  void shuffleCards() {
    _isShuffled = true;
    final random = Random();
    _cards = List.from(_cards)..shuffle(random);
    _currentIndex = 0;
    _isFlipped = false;
    _isComplete = false;
    notifyListeners();
  }

  /// Restart session
  void restart() {
    _currentIndex = 0;
    _isFlipped = false;
    _isComplete = false;
    if (_isShuffled) {
      shuffleCards();
    } else {
      _cards = List.from(_originalCards);
    }
    notifyListeners();
  }

  /// Toggle favorite for current card
  Future<void> toggleFavorite() async {
    final card = currentCard;
    if (card == null) return;
    final newFav = !card.isFavorite;
    await FlashcardDao.instance.toggleFavorite(card.id, newFav);
    _cards[_currentIndex] = card.copyWith(isFavorite: newFav);
    final origIdx = _originalCards.indexWhere((c) => c.id == card.id);
    if (origIdx != -1) {
      _originalCards[origIdx] = _cards[_currentIndex];
    }
    notifyListeners();
  }

  /// Record this card study in history
  Future<void> _recordStudy() async {
    final card = currentCard;
    if (card == null) return;
    final entry = StudyHistoryModel(
      id: const Uuid().v4(),
      flashcardId: card.id,
      categoryId: card.categoryId,
      wasCorrect: _isFlipped, // considered "correct" if they revealed the answer
      studiedAt: DateTime.now(),
    );
    await StudyHistoryDao.instance.insert(entry);
  }

  /// Reset state
  void reset() {
    _cards = [];
    _originalCards = [];
    _currentIndex = 0;
    _isFlipped = false;
    _isShuffled = false;
    _isComplete = false;
  }
}
