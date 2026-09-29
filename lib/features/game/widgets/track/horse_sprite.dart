import 'package:flutter/material.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/race_track_system.dart';

class HorseSprite extends StatelessWidget {
  const HorseSprite({
    super.key,
    required this.color,
    required this.isRunning,
    required this.isWinner,
  });

  final Color color;
  final bool isRunning;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isWinner ? 'Winner horse' : 'Race horse',
      image: true,
      child: AnimatedScale(
        scale: isWinner ? 1.18 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        child: SizedBox(
          width: RaceTrackSystem.horseWidth,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AnimatedRotation(
                turns: isRunning ? -0.025 : 0,
                duration: const Duration(milliseconds: 100),
                child: const Text('🐎', style: TextStyle(fontSize: 38)),
              ),
              Positioned(
                right: 7,
                top: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const SizedBox(width: 16, height: 16),
                ),
              ),
              if (isWinner)
                const Positioned(
                  top: 0,
                  child: Icon(Icons.workspace_premium, color: Colors.amber),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
