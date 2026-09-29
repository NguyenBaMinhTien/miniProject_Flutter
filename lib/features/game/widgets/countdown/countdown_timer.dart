// DEV 3 Scope: Betting & Game Loop UI
import 'package:flutter/material.dart';

import '../track/models/race_phase.dart';

/// Chỉ hiển thị countdown do server (GameController.countdown) gửi xuống,
/// không tự đếm giờ.
class CountdownTimer extends StatelessWidget {
  const CountdownTimer({
    super.key,
    required this.seconds,
    required this.phase,
  });

  final int seconds;
  final RacePhase phase;

  String get _caption => switch (phase) {
    RacePhase.betting => 'Khóa cược sau',
    RacePhase.racing => 'Cuộc đua đang diễn ra',
    RacePhase.finished => 'Vòng mới sau',
    RacePhase.cancelled => 'Mở cược lại sau',
  };

  @override
  Widget build(BuildContext context) {
    final showNumber = phase != RacePhase.racing && seconds > 0;
    final urgent = phase == RacePhase.betting && seconds <= 3;
    final color = urgent ? Colors.red : Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined, size: 18, color: color),
        const SizedBox(width: 6),
        Text(_caption, style: TextStyle(color: color)),
        if (showNumber) ...[
          const SizedBox(width: 8),
          AnimatedScale(
            scale: urgent ? 1.2 : 1,
            duration: const Duration(milliseconds: 200),
            child: Text(
              '${seconds}s',
              key: const Key('countdown-seconds'),
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
