import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/controllers/race_track_controller.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/horse_lane_widget.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/models/race_phase.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/race_track_system.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/winner_celebration.dart';
import 'package:flutter_horse_racing/models/horse.dart';

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

  // We set a virtual track width that is much wider than the screen
  static const double _virtualTrackWidth = 2400.0;

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

        // Find leading horse position to calculate camera
        final maxPos = _controller.positions.fold<double>(
            0.0, (m, p) => p > m ? p : m);

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            
            // Camera follows the leading horse. We want the leading horse 
            // to be around 70% of the screen width from the left edge.
            double cameraX = (maxPos / 100.0) * _virtualTrackWidth - (screenWidth * 0.7);
            
            // Clamp camera between start and end of track
            if (cameraX < 0) cameraX = 0;
            final maxCamera = _virtualTrackWidth - screenWidth;
            if (cameraX > maxCamera) cameraX = maxCamera;

            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 1. Zoomed in Virtual Track layer (moves opposite to camera)
                  Positioned(
                    left: -cameraX,
                    top: 0,
                    bottom: 0,
                    width: _virtualTrackWidth,
                    child: Stack(
                      children: [
                        // Background road SVG
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/road/road1.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                        // Dark overlay to make lanes visible
                        Positioned.fill(
                          child: ColoredBox(color: Colors.black38),
                        ),
                        // Lanes and Horses
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(
                            _controller.horses.length,
                            (index) => HorseLaneWidget(
                              horse: _controller.horses[index],
                              position: _controller.positions[index],
                              phase: _controller.phase,
                              laneNumber: index + 1,
                              isWinner: _controller.horses[index].id ==
                                  _controller.winnerHorseId,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 2. Track Header (Fixed)
                  const Positioned(
                    left: 0, right: 0, top: 0,
                    child: _TrackHeader(),
                  ),

                  // 3. Mini-map Overlay (Top Right)
                  Positioned(
                    top: 40,
                    right: 12,
                    child: _MinimapWidget(
                      horses: _controller.horses,
                      positions: _controller.positions,
                    ),
                  ),

                  // 4. Winner Celebration Overlay
                  if (showCelebration)
                    WinnerCelebration(
                      key: ValueKey(_controller.winnerHorseId),
                      horse: _controller.horses[winnerIndex],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TrackHeader extends StatelessWidget {
  const _TrackHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: const <Widget>[
          Icon(Icons.flag, color: Colors.amber, size: 18),
          SizedBox(width: 6),
          Text(
            'ĐƯỜNG ĐUA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

class _MinimapWidget extends StatelessWidget {
  const _MinimapWidget({
    required this.horses,
    required this.positions,
  });

  final List<Horse> horses;
  final List<double> positions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        border: Border.all(color: Colors.white30),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(horses.length, (index) {
          final pos = positions[index].clamp(0.0, 100.0);
          final color = RaceTrackSystem.parseHorseColor(
            horses[index].color,
            fallbackIndex: index,
          );
          return Row(
            children: [
              Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 8)),
              const SizedBox(width: 4),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(height: 2, color: Colors.white24),
                    Positioned(
                      left: pos > 0 ? (pos / 100) * 80 : 0, // Approx width 100 minus padding
                      child: Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
