import 'package:flutter/material.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/controllers/race_track_controller.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/finish_line.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/horse_lane_widget.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/models/race_phase.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/race_track_system.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/winner_celebration.dart';
import 'package:flutter_horse_racing/models/horse.dart';

/// Public, provider-agnostic race-track view consumed by Dev 3's GameScreen.
class RaceTrackWidget extends StatefulWidget {
  const RaceTrackWidget({
    super.key,
    required this.horses,
    required this.positions,
    required this.phase,
    this.winnerHorseId,
  });

  final List<Horse> horses;
  final List<double> positions;
  final RacePhase phase;
  final String? winnerHorseId;

  @override
  State<RaceTrackWidget> createState() => _RaceTrackWidgetState();
}

class _RaceTrackWidgetState extends State<RaceTrackWidget> {
  late final RaceTrackController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RaceTrackController(
      horses: widget.horses,
      positions: widget.positions,
      phase: widget.phase,
      winnerHorseId: widget.winnerHorseId,
    );
  }

  @override
  void didUpdateWidget(covariant RaceTrackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.update(
      horses: widget.horses,
      positions: widget.positions,
      phase: widget.phase,
      winnerHorseId: widget.winnerHorseId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final winnerIndex = _controller.winnerHorseId == null
            ? -1
            : _controller.horses.indexWhere(
                (horse) => horse.id == _controller.winnerHorseId,
              );
        final showCelebration =
            _controller.phase.isFinished && winnerIndex >= 0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: RaceTrackSystem.panel,
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const _TrackHeader(),
                    Stack(
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List<Widget>.generate(
                            _controller.horses.length,
                            (index) => HorseLaneWidget(
                              horse: _controller.horses[index],
                              position: _controller.positions[index],
                              phase: _controller.phase,
                              laneNumber: index + 1,
                              isWinner:
                                  _controller.horses[index].id ==
                                  _controller.winnerHorseId,
                            ),
                          ),
                        ),
                        const Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: FinishLine(),
                        ),
                      ],
                    ),
                  ],
                ),
                if (showCelebration)
                  WinnerCelebration(
                    key: ValueKey(_controller.winnerHorseId),
                    horse: _controller.horses[winnerIndex],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrackHeader extends StatelessWidget {
  const _TrackHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 34,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: <Widget>[
            Icon(Icons.flag, color: Colors.amber, size: 18),
            SizedBox(width: 6),
            Text(
              'ĐƯỜNG ĐUA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            Spacer(),
            Text('ĐÍCH', style: TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
