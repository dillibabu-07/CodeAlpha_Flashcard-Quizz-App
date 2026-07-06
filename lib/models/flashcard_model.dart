// lib/models/flashcard_model.dart

enum Difficulty { easy, medium, hard }

extension DifficultyExtension on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  String get value {
    return name; // 'easy', 'medium', 'hard'
  }

  static Difficulty fromString(String s) {
    return Difficulty.values.firstWhere(
      (d) => d.name == s.toLowerCase(),
      orElse: () => Difficulty.medium,
    );
  }
}

class FlashcardModel {
  final String id;
  final String question;
  final String answer;
  final String categoryId;
  final Difficulty difficulty;
  final List<String> tags;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional: category name for display (joined from DB)
  final String? categoryName;

  FlashcardModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.categoryId,
    required this.difficulty,
    required this.tags,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
  });

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category_id': categoryId,
      'difficulty': difficulty.value,
      'tags': tags.join(','),
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from SQLite map
  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    final tagsStr = map['tags'] as String? ?? '';
    return FlashcardModel(
      id: map['id'] as String,
      question: map['question'] as String,
      answer: map['answer'] as String,
      categoryId: map['category_id'] as String,
      difficulty: DifficultyExtension.fromString(map['difficulty'] as String? ?? 'medium'),
      tags: tagsStr.isEmpty ? [] : tagsStr.split(',').map((t) => t.trim()).toList(),
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      categoryName: map['category_name'] as String?,
    );
  }

  /// Copy with updated fields
  FlashcardModel copyWith({
    String? id,
    String? question,
    String? answer,
    String? categoryId,
    Difficulty? difficulty,
    List<String>? tags,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      categoryId: categoryId ?? this.categoryId,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? List.from(this.tags),
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      categoryName: categoryName ?? this.categoryName,
    );
  }

  /// JSON for export
  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'categoryId': categoryId,
        'difficulty': difficulty.value,
        'tags': tags,
        'isFavorite': isFavorite,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      categoryId: json['categoryId'] as String,
      difficulty: DifficultyExtension.fromString(json['difficulty'] as String),
      tags: (json['tags'] as List<dynamic>).map((t) => t.toString()).toList(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FlashcardModel && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FlashcardModel(id: $id, question: $question)';
}
