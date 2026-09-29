// DEV 3 Scope: Betting & Game Loop UI
import 'package:flutter/material.dart';

import '../track/models/race_phase.dart';

class PhaseBanner extends StatelessWidget {
  const PhaseBanner({super.key, required this.phase});

  final RacePhase phase;

  static String labelOf(RacePhase phase) => switch (phase) {
    RacePhase.betting => 'ĐANG MỞ CƯỢC',
    RacePhase.racing => 'ĐANG ĐUA',
    RacePhase.finished => 'KẾT QUẢ',
    RacePhase.cancelled => 'ĐÃ HỦY',
  };

  static (Color, IconData) _styleOf(RacePhase phase) => switch (phase) {
    RacePhase.betting => (const Color(0xFF2E7D32), Icons.casino),
    RacePhase.racing => (const Color(0xFFE65100), Icons.bolt),
    RacePhase.finished => (const Color(0xFF1565C0), Icons.emoji_events),
    RacePhase.cancelled => (const Color(0xFFC62828), Icons.block),
  };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _styleOf(phase);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            labelOf(phase),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
