import 'package:flutter/foundation.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/models/race_phase.dart';
import 'package:flutter_horse_racing/models/horse.dart';

/// Owns race-track presentation state while the backend remains the source of
/// truth. It normalizes incoming ticks but never calculates a winner.
class RaceTrackController extends ChangeNotifier {
  RaceTrackController({
    required List<Horse> horses,
    required List<double> positions,
    required RacePhase phase,
    String? winnerHorseId,
  }) : _horses = List<Horse>.unmodifiable(horses),
       _positions = _normalize(horses, positions),
       _phase = phase,
       _winnerHorseId = winnerHorseId;

  List<Horse> _horses;
  List<double> _positions;
  RacePhase _phase;
  String? _winnerHorseId;

  List<Horse> get horses => _horses;
  List<double> get positions => _positions;
  RacePhase get phase => _phase;
  String? get winnerHorseId => _winnerHorseId;

  void update({
    required List<Horse> horses,
    required List<double> positions,
    required RacePhase phase,
    String? winnerHorseId,
  }) {
    final normalizedPositions = _normalize(horses, positions);
    final nextHorses = List<Horse>.unmodifiable(horses);
    final changed =
        !listEquals(_horses, nextHorses) ||
        !listEquals(_positions, normalizedPositions) ||
        _phase != phase ||
        _winnerHorseId != winnerHorseId;

    _horses = nextHorses;
    _positions = normalizedPositions;
    _phase = phase;
    _winnerHorseId = winnerHorseId;
    if (changed) notifyListeners();
  }

  static List<double> _normalize(List<Horse> horses, List<double> positions) {
    if (horses.isEmpty || horses.length > 5) {
      throw ArgumentError.value(
        horses.length,
        'horses',
        'Race track requires between 1 and 5 horses.',
      );
    }
    if (positions.length != horses.length) {
      throw ArgumentError(
        'positions (${positions.length}) must match horses (${horses.length}).',
      );
    }
    return List<double>.unmodifiable(
      positions.map((position) {
        if (!position.isFinite) return 0.0;
        return position.clamp(0.0, 100.0).toDouble();
      }),
    );
  }
}
