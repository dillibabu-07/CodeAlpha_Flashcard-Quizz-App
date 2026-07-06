// lib/widgets/quiz/option_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

enum OptionState { idle, selected, correct, wrong }

class OptionButton extends StatelessWidget {
  final String label;
  final String optionLetter; // A, B, C, D
  final OptionState state;
  final VoidCallback? onTap;

  const OptionButton({
    super.key,
    required this.label,
    required this.optionLetter,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor;
    Color borderColor;
    Color textColor;
    Color letterBg;
    IconData? trailingIcon;

    switch (state) {
      case OptionState.correct:
        bgColor = AppColors.success.withOpacity(0.12);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        letterBg = AppColors.success;
        trailingIcon = Icons.check_circle_rounded;
        break;
      case OptionState.wrong:
        bgColor = AppColors.error.withOpacity(0.12);
        borderColor = AppColors.error;
        textColor = AppColors.error;
        letterBg = AppColors.error;
        trailingIcon = Icons.cancel_rounded;
        break;
      case OptionState.selected:
        bgColor = AppColors.primary.withOpacity(0.12);
        borderColor = AppColors.primary;
        textColor = AppColors.primary;
        letterBg = AppColors.primary;
        trailingIcon = null;
        break;
      case OptionState.idle:
        bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        borderColor = Theme.of(context).dividerColor;
        textColor = Theme.of(context).colorScheme.onSurface;
        letterBg = Theme.of(context).colorScheme.surfaceContainerHighest;
        trailingIcon = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: state != OptionState.idle
            ? [
                BoxShadow(
                  color: borderColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state == OptionState.idle ? onTap : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                // Letter indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: state == OptionState.idle ? letterBg : borderColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      optionLetter,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: state == OptionState.idle
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: state != OptionState.idle
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailingIcon, color: borderColor, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
