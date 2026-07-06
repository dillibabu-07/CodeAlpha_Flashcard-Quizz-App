// lib/animations/confetti_overlay.dart
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.trigger,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.trigger) _controller.play();
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: MediaQuery.of(context).size.width / 2,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirection: pi / 2, // downward
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 30,
            minBlastForce: 10,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.2,
            colors: const [
              Color(0xFF2563EB),
              Color(0xFF10B981),
              Color(0xFFF59E0B),
              Color(0xFFEF4444),
              Color(0xFF7C3AED),
              Color(0xFFDB2777),
            ],
          ),
        ),
      ],
    );
  }
}
