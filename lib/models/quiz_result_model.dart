// lib/models/quiz_result_model.dart

class QuizResultModel {
  final String id;
  final String categoryId;
  final String? categoryName;
  final int score;
  final int total;
  final double percentage;
  final int durationSeconds;
  final DateTime createdAt;

  QuizResultModel({
    required this.id,
    required this.categoryId,
    this.categoryName,
    required this.score,
    required this.total,
    required this.percentage,
    required this.durationSeconds,
    required this.createdAt,
  });

  String get performanceMessage {
    if (percentage >= 90) return 'Excellent! 🏆';
    if (percentage >= 75) return 'Great Job! 🎯';
    if (percentage >= 60) return 'Good Work! 👍';
    if (percentage >= 40) return 'Keep Practicing! 💪';
    return 'Needs More Practice! 📚';
  }

  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m}m ${s}s';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category_id': categoryId,
        'score': score,
        'total': total,
        'percentage': percentage,
        'duration_seconds': durationSeconds,
        'created_at': createdAt.toIso8601String(),
      };

  factory QuizResultModel.fromMap(Map<String, dynamic> map) {
    return QuizResultModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      categoryName: map['category_name'] as String?,
      score: map['score'] as int,
      total: map['total'] as int,
      percentage: (map['percentage'] as num).toDouble(),
      durationSeconds: map['duration_seconds'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'score': score,
        'total': total,
        'percentage': percentage,
        'durationSeconds': durationSeconds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      score: json['score'] as int,
      total: json['total'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      durationSeconds: json['durationSeconds'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// A single quiz question with options
class QuizQuestion {
  final FlashcardRef flashcard;
  final String correctAnswer;
  final List<String> options; // shuffled list of 4 options
  int? selectedOptionIndex;

  QuizQuestion({
    required this.flashcard,
    required this.correctAnswer,
    required this.options,
    this.selectedOptionIndex,
  });

  bool get isAnswered => selectedOptionIndex != null;

  bool get isCorrect {
    if (!isAnswered) return false;
    if (selectedOptionIndex! < 0) return false; // timer expired
    return options[selectedOptionIndex!] == correctAnswer;
  }

  int get correctIndex => options.indexOf(correctAnswer);
}

/// Lightweight flashcard reference for quiz questions
class FlashcardRef {
  final String id;
  final String question;
  final String answer;

  FlashcardRef({
    required this.id,
    required this.question,
    required this.answer,
  });
}
