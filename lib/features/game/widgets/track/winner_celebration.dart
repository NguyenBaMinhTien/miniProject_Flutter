import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/horse_sprite.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/race_track_system.dart';
import 'package:flutter_horse_racing/models/horse.dart';

class WinnerCelebration extends StatefulWidget {
  const WinnerCelebration({
    super.key,
    required this.horse,
    this.duration = RaceTrackSystem.winnerDuration,
  });

  final Horse horse;
  final Duration duration;

  @override
  State<WinnerCelebration> createState() => _WinnerCelebrationState();
}

class _WinnerCelebrationState extends State<WinnerCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _visible = false);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final color = RaceTrackSystem.parseHorseColor(widget.horse.color);
    return Positioned.fill(
      key: const Key('winner-celebration'),
      child: IgnorePointer(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.68),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ConfettiPainter(_controller.value),
                  ),
                ),
                Transform.scale(
                  scale:
                      0.75 +
                      Curves.elasticOut.transform(
                            math.min(1, _controller.value * 3),
                          ) *
                          0.25,
                  child: child,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  '🏆 CHIẾN THẮNG',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                HorseSprite(color: color, isRunning: false, isWinner: true),
                Text(
                  widget.horse.name,
                  key: const Key('winner-name'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter(this.progress);

  final double progress;

  static const colors = <Color>[
    Colors.amber,
    Colors.redAccent,
    Colors.lightBlueAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < 28; index++) {
      final x = ((index * 47) % 101) / 100 * size.width;
      final start = ((index * 31) % 83) / 83;
      final y =
          ((start + progress * (1.2 + index % 3 * .15)) % 1.15) * size.height;
      final paint = Paint()..color = colors[index % colors.length];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * (index.isEven ? 2 : -2));
      canvas.drawRect(const Rect.fromLTWH(-3, -6, 6, 12), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
