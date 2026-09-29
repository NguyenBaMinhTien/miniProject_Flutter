import 'dart:math' as math;

import 'package:flutter/material.dart';

class DustEffect extends StatefulWidget {
  const DustEffect({super.key});

  @override
  State<DustEffect> createState() => _DustEffectState();
}

class _DustEffectState extends State<DustEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          size: const Size(36, 24),
          painter: _DustPainter(_controller.value),
        ),
      ),
    );
  }
}

class _DustPainter extends CustomPainter {
  const _DustPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x99E8C38E);
    for (var index = 0; index < 4; index++) {
      final t = (progress + index / 4) % 1;
      final radius = 2 + (1 - t) * 3;
      final y = size.height * .65 + math.sin(index * 2.1) * 5;
      canvas.drawCircle(Offset(size.width * (1 - t), y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
