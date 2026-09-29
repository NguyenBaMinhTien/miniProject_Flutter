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
            color: laneNumber.isEven
                ? RaceTrackSystem.grassDark
                : RaceTrackSystem.grass,
            border: const Border(
              bottom: BorderSide(color: RaceTrackSystem.laneLine),
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
                          RaceTrackSystem.horseWidth -
                          RaceTrackSystem.finishLineWidth,
                    );
                    final targetLeft = travelWidth * safePosition / 100;
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        TweenAnimationBuilder<double>(
                          key: Key('horse-position-${horse.id}'),
                          tween: Tween<double>(begin: 0, end: targetLeft),
                          duration: phase.isRacing
                              ? RaceTrackSystem.raceTickDuration
                              : RaceTrackSystem.idleMoveDuration,
                          curve: Curves.linear,
                          builder: (context, left, child) =>
                              Positioned(left: left, top: 8, child: child!),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              if (phase.isRacing)
                                const Positioned(
                                  key: Key('dust-effect'),
                                  left: -20,
                                  top: 21,
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
                            color: Colors.black.withValues(alpha: 0.08),
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
