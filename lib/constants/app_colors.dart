// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary / Accent
  static const Color secondary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF10B981);
  static const Color accentLight = Color(0xFF34D399);

  // Difficulty colors
  static const Color easy = Color(0xFF10B981);
  static const Color medium = Color(0xFFF59E0B);
  static const Color hard = Color(0xFFEF4444);

  // Light theme
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextHint = Color(0xFF94A3B8);

  // Dark theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextHint = Color(0xFF64748B);

  // Category colors
  static const List<Color> categoryColors = [
    Color(0xFF2563EB), // Blue
    Color(0xFF7C3AED), // Purple
    Color(0xFF059669), // Green
    Color(0xFFD97706), // Amber
    Color(0xFFDC2626), // Red
    Color(0xFF0891B2), // Cyan
    Color(0xFFDB2777), // Pink
    Color(0xFF65A30D), // Lime
    Color(0xFF9333EA), // Violet
    Color(0xFF0284C7), // Sky
  ];

  // Gradient pairs for category cards
  static const List<List<Color>> categoryGradients = [
    [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    [Color(0xFF7C3AED), Color(0xFF6D28D9)],
    [Color(0xFF059669), Color(0xFF047857)],
    [Color(0xFFD97706), Color(0xFFB45309)],
    [Color(0xFFDC2626), Color(0xFFB91C1C)],
    [Color(0xFF0891B2), Color(0xFF0E7490)],
    [Color(0xFFDB2777), Color(0xFFBE185D)],
    [Color(0xFF65A30D), Color(0xFF4D7C0F)],
    [Color(0xFF9333EA), Color(0xFF7E22CE)],
    [Color(0xFF0284C7), Color(0xFF0369A1)],
  ];

  // Header gradient
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E40AF)],
  );

  // Study card gradient
  static const LinearGradient studyCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  // Success / Error
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
