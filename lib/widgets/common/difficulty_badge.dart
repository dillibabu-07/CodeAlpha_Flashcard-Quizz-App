// lib/widgets/common/difficulty_badge.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/flashcard_model.dart';
import '../../utils/extensions.dart';

class DifficultyBadge extends StatelessWidget {
  final Difficulty difficulty;
  final bool showEmoji;
  final bool small;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.showEmoji = true,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: difficulty.bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: difficulty.color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showEmoji) ...[
            Text(difficulty.emoji, style: TextStyle(fontSize: small ? 10 : 12)),
            const SizedBox(width: 4),
          ],
          Text(
            difficulty.label,
            style: GoogleFonts.inter(
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: difficulty.color,
            ),
          ),
        ],
      ),
    );
  }
}
