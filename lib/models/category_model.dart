// lib/models/category_model.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CategoryModel {
  final String id;
  final String name;
  final int iconCode; // IconData.codePoint
  final String colorHex;
  final DateTime createdAt;
  int cardCount; // computed, not stored in DB

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorHex,
    required this.createdAt,
    this.cardCount = 0,
  });

  /// IconData from stored codePoint
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  /// Color from hex string
  Color get color {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code': iconCode,
      'color_hex': colorHex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from SQLite map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCode: map['icon_code'] as int,
      colorHex: map['color_hex'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      cardCount: map['card_count'] as int? ?? 0,
    );
  }

  /// Copy with updated fields
  CategoryModel copyWith({
    String? id,
    String? name,
    int? iconCode,
    String? colorHex,
    DateTime? createdAt,
    int? cardCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      cardCount: cardCount ?? this.cardCount,
    );
  }

  /// JSON for export
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCode': iconCode,
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCode: json['iconCode'] as int,
      colorHex: json['colorHex'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CategoryModel && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryModel(id: $id, name: $name)';
}

/// Predefined category icon options
class CategoryIcons {
  static const List<Map<String, dynamic>> options = [
    {'label': 'Code', 'icon': Icons.code},
    {'label': 'Book', 'icon': Icons.menu_book},
    {'label': 'Science', 'icon': Icons.science},
    {'label': 'Math', 'icon': Icons.calculate},
    {'label': 'Language', 'icon': Icons.translate},
    {'label': 'History', 'icon': Icons.history_edu},
    {'label': 'Art', 'icon': Icons.palette},
    {'label': 'Music', 'icon': Icons.music_note},
    {'label': 'Sports', 'icon': Icons.sports_soccer},
    {'label': 'Tech', 'icon': Icons.computer},
    {'label': 'Brain', 'icon': Icons.psychology},
    {'label': 'Data', 'icon': Icons.storage},
    {'label': 'Network', 'icon': Icons.hub},
    {'label': 'AI', 'icon': Icons.smart_toy},
    {'label': 'Database', 'icon': Icons.table_chart},
    {'label': 'Security', 'icon': Icons.security},
    {'label': 'Cloud', 'icon': Icons.cloud},
    {'label': 'Mobile', 'icon': Icons.phone_android},
    {'label': 'Globe', 'icon': Icons.public},
    {'label': 'Star', 'icon': Icons.star},
  ];
}
