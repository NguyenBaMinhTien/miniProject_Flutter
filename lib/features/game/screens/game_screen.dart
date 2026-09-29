import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/race_track_widget.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/models/race_phase.dart';
import 'package:flutter_horse_racing/models/horse.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<Horse> _horses = const [
    Horse(id: 'h1', name: 'Bạch Mã', color: 'red'),
    Horse(id: 'h2', name: 'Xích Thố', color: 'blue'),
    Horse(id: 'h3', name: 'Hắc Phong', color: 'green'),
    Horse(id: 'h4', name: 'Phi Yến', color: 'yellow'),
    Horse(id: 'h5', name: 'Lôi Thần', color: 'purple'),
  ];
  
  List<double> _positions = [0.0, 0.0, 0.0, 0.0, 0.0];
  RacePhase _phase = RacePhase.betting;
  String? _winnerId;
  Timer? _timer;
  final _random = math.Random();

  void _startRace() {
    setState(() {
      _positions = [0.0, 0.0, 0.0, 0.0, 0.0];
      _phase = RacePhase.racing;
      _winnerId = null;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      bool finished = false;
      setState(() {
        for (int i = 0; i < _positions.length; i++) {
          _positions[i] += _random.nextDouble() * 2.0; 
          if (_positions[i] >= 100.0) {
            _positions[i] = 100.0;
            finished = true;
            _winnerId ??= _horses[i].id;
          }
        }
        
        if (finished) {
          _phase = RacePhase.finished;
          timer.cancel();
        }
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _positions = [0.0, 0.0, 0.0, 0.0, 0.0];
      _phase = RacePhase.betting;
      _winnerId = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Race Game Concept'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: RaceTrackWidget(
              horses: _horses,
              positions: _positions,
              phase: _phase,
              winnerHorseId: _winnerId,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Colors.black87,
              border: Border(top: BorderSide(color: Colors.white24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: _reset,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.flag),
                  label: const Text('Bắt đầu đua!'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  onPressed: _phase == RacePhase.racing ? null : _startRace,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
