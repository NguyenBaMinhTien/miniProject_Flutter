import 'package:flutter_horse_racing/features/game/widgets/track/models/race_phase.dart';
import 'package:flutter_horse_racing/models/horse.dart';

abstract final class RaceTrackMockData {
  static const List<Horse> horses = <Horse>[
    Horse(id: 'horse-1', name: 'Xích Thố', color: 'red'),
    Horse(id: 'horse-2', name: 'Lam Phong', color: 'blue'),
    Horse(id: 'horse-3', name: 'Kim Mã', color: 'gold'),
    Horse(id: 'horse-4', name: 'Tử Điện', color: 'purple'),
    Horse(id: 'horse-5', name: 'Lục Vân', color: 'green'),
  ];

  static const List<double> positions = <double>[10, 20, 30, 40, 50];
  static const RacePhase phase = RacePhase.racing;
}
