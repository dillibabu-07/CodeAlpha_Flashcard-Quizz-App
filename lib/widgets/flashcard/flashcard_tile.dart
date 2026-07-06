// lib/widgets/flashcard/flashcard_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../models/flashcard_model.dart';
import '../../utils/extensions.dart';
import '../common/difficulty_badge.dart';

class FlashcardTile extends StatelessWidget {
  final FlashcardModel card;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final VoidCallback? onDuplicate;
  final Color? accentColor;

  const FlashcardTile({
    super.key,
    required this.card,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onFavorite,
    this.onDuplicate,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.xs),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: category + favorite
            Row(
              children: [
                if (card.categoryName != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      card.categoryName!,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.xs),
                ],
                DifficultyBadge(difficulty: card.difficulty, small: true),
                const Spacer(),
                // Favorite button
                GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    card.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: card.isFavorite
                        ? Colors.red.shade400
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.xs),
                // More actions menu
                if (onEdit != null || onDelete != null || onDuplicate != null)
                  _MoreMenu(card: card, onEdit: onEdit, onDelete: onDelete, onDuplicate: onDuplicate),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            // Question
            Text(
              card.question,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.xs),
            // Answer preview
            Text(
              card.answer,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (card.tags.isNotEmpty) ...[
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: card.tags
                    .take(3)
                    .map((tag) => _TagChip(tag: tag))
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSizes.xs),
            // Footer: date
            Text(
              card.updatedAt.relativeTime,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '#$tag',
        style: GoogleFonts.inter(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  final FlashcardModel card;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const _MoreMenu({
    required this.card,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 18,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: _MenuItem(icon: Icons.edit_outlined, label: 'Edit')),
        const PopupMenuItem(value: 'duplicate', child: _MenuItem(icon: Icons.copy_outlined, label: 'Duplicate')),
        const PopupMenuItem(value: 'delete', child: _MenuItem(icon: Icons.delete_outline_rounded, label: 'Delete', isDestructive: true)),
      ],
      onSelected: (val) {
        if (val == 'edit') onEdit?.call();
        if (val == 'duplicate') onDuplicate?.call();
        if (val == 'delete') onDelete?.call();
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color, fontSize: 14)),
      ],
    );
  }
}
