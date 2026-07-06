// lib/models/study_history_model.dart

class StudyHistoryModel {
  final String id;
  final String? userId;
  final String flashcardId;
  final String categoryId;
  final bool wasCorrect;
  final DateTime studiedAt;

  StudyHistoryModel({
    required this.id,
    this.userId,
    required this.flashcardId,
    required this.categoryId,
    required this.wasCorrect,
    required this.studiedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'flashcard_id': flashcardId,
        'category_id': categoryId,
        'was_correct': wasCorrect ? 1 : 0,
        'studied_at': studiedAt.toIso8601String(),
      };

  factory StudyHistoryModel.fromMap(Map<String, dynamic> map) {
    return StudyHistoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      flashcardId: map['flashcard_id'] as String,
      categoryId: map['category_id'] as String,
      wasCorrect: (map['was_correct'] as int) == 1,
      studiedAt: DateTime.parse(map['studied_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'flashcardId': flashcardId,
        'categoryId': categoryId,
        'wasCorrect': wasCorrect,
        'studiedAt': studiedAt.toIso8601String(),
      };

  factory StudyHistoryModel.fromJson(Map<String, dynamic> json) {
    return StudyHistoryModel(
      id: json['id'] as String,
      flashcardId: json['flashcardId'] as String,
      categoryId: json['categoryId'] as String,
      wasCorrect: json['wasCorrect'] as bool,
      studiedAt: DateTime.parse(json['studiedAt'] as String),
    );
  }
}

/// Aggregated daily study stats (for charts)
class DailyStudyStat {
  final DateTime date;
  final int cardsStudied;
  final int correctAnswers;

  DailyStudyStat({
    required this.date,
    required this.cardsStudied,
    required this.correctAnswers,
  });

  double get accuracy =>
      cardsStudied == 0 ? 0 : (correctAnswers / cardsStudied) * 100;
}
