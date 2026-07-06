// lib/utils/extensions.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/flashcard_model.dart';

extension StringExtension on String {
  /// Capitalize first letter
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Truncate with ellipsis
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';
}

extension DateTimeExtension on DateTime {
  /// Format as 'Mon, 06 Jul 2026'
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[weekday - 1];
    final monthName = months[month - 1];
    return '$dayName, ${day.toString().padLeft(2, '0')} $monthName $year';
  }

  /// Format as 'HH:MM AM/PM'
  String get formattedTime {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  /// Relative time: '2 days ago', 'Just now', etc.
  String get relativeTime {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formattedDate;
  }

  /// Short date for charts: 'Mon', 'Tue', etc.
  String get shortDayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

extension DifficultyColor on Difficulty {
  Color get color {
    switch (this) {
      case Difficulty.easy:
        return AppColors.easy;
      case Difficulty.medium:
        return AppColors.medium;
      case Difficulty.hard:
        return AppColors.hard;
    }
  }

  Color get bgColor {
    switch (this) {
      case Difficulty.easy:
        return AppColors.easy.withOpacity(0.12);
      case Difficulty.medium:
        return AppColors.medium.withOpacity(0.12);
      case Difficulty.hard:
        return AppColors.hard.withOpacity(0.12);
    }
  }

  String get emoji {
    switch (this) {
      case Difficulty.easy:
        return '🟢';
      case Difficulty.medium:
        return '🟡';
      case Difficulty.hard:
        return '🔴';
    }
  }
}

extension ColorExtension on Color {
  /// Convert to hex string '#RRGGBB'
  String get toHex =>
      '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
}

extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
