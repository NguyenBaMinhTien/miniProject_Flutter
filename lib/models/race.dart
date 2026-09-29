import 'horse.dart';
import 'race_state_model.dart';

@Deprecated('Use RaceStateModel')
class Race extends RaceStateModel {
  const Race({
    required this.id,
    required this.horses,
    required this.status,
  }) : super(
          raceId: id,
          raceNumber: 0,
          phase: RacePhase.waiting,
          countdown: 0,
          horses: horses,
          positions: const {},
        );

  final String id;
  @override
  final List<Horse> horses;
  final String status;
}
