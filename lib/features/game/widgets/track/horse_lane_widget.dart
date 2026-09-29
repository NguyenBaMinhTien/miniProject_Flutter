import 'package:flutter/material.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/dust_effect.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/horse_sprite.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/models/race_phase.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/race_track_system.dart';
import 'package:flutter_horse_racing/models/horse.dart';

class HorseLaneWidget extends StatelessWidget {
  const HorseLaneWidget({
    super.key,
    required this.horse,
    required this.position,
    required this.phase,
    required this.laneNumber,
    this.isWinner = false,
  });

  final Horse horse;
  final double position;
  final RacePhase phase;
  final int laneNumber;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final safePosition = position.isFinite
        ? position.clamp(0.0, 100.0).toDouble()
        : 0.0;
    final horseColor = RaceTrackSystem.parseHorseColor(
      horse.color,
      fallbackIndex: laneNumber - 1,
    );

    return Semantics(
      container: true,
      label: 'Lane $laneNumber, ${horse.name}, ${safePosition.round()} percent',
      child: SizedBox(
        key: Key('lane-$laneNumber'),
        height: RaceTrackSystem.laneHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.transparent, // the lane background will be handled by the track
            border: const Border(
              bottom: BorderSide(color: Colors.white24, width: 0.5),
            ),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 42,
                child: Center(
                  child: Text(
                    '$laneNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final travelWidth = mathMax(
                      0,
                      constraints.maxWidth -
                          80 - // Horse sprite width
                          RaceTrackSystem.finishLineWidth,
                    );
                    final targetLeft = travelWidth * safePosition / 100;
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        TweenAnimationBuilder<double>(
                          key: Key('horse-position-${horse.id}'),
                          tween: Tween<double>(begin: targetLeft, end: targetLeft),
                          // Disable tweening here because the parent's camera movement 
                          // plus tweening can look jerky. We rely on the parent updating states smoothly.
                          duration: phase.isRacing
                              ? const Duration(milliseconds: 100)
                              : RaceTrackSystem.idleMoveDuration,
                          curve: Curves.linear,
                          builder: (context, left, child) =>
                              Positioned(left: left, top: 4, child: child!),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              if (phase.isRacing)
                                const Positioned(
                                  key: Key('dust-effect'),
                                  left: -20,
                                  top: 25,
                                  child: DustEffect(),
                                ),
                              HorseSprite(
                                key: Key('horse-${horse.id}'),
                                color: horseColor,
                                isRunning: phase.isRacing,
                                isWinner: isWinner,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: RaceTrackSystem.finishLineWidth,
                          child: ColoredBox(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double mathMax(double first, double second) => first > second ? first : second;
