// lib/widgets/common/gradient_header.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class GradientHeader extends StatelessWidget {
  final Widget child;
  final double? height;
  final List<Color>? colors;
  final BorderRadius? borderRadius;

  const GradientHeader({
    super.key,
    required this.child,
    this.height,
    this.colors,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ??
              const [
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
                Color(0xFF1E40AF),
              ],
        ),
        borderRadius: borderRadius ??
            const BorderRadius.only(
              bottomLeft: Radius.circular(AppSizes.radiusXXL),
              bottomRight: Radius.circular(AppSizes.radiusXXL),
            ),
      ),
      child: child,
    );
  }
}

/// Decorative circle overlay for header backgrounds
class HeaderDecoration extends StatelessWidget {
  const HeaderDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -40,
          child: _decorativeCircle(120, Colors.white.withOpacity(0.06)),
        ),
        Positioned(
          bottom: -20,
          left: -30,
          child: _decorativeCircle(100, Colors.white.withOpacity(0.04)),
        ),
        Positioned(
          top: 20,
          right: 80,
          child: _decorativeCircle(60, Colors.white.withOpacity(0.08)),
        ),
      ],
    );
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
