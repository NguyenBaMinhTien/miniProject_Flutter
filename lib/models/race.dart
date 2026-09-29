import 'horse.dart';

@Deprecated('Use RaceStateModel')
class Race {
  const Race({
    required this.id,
    required this.horses,
    required this.status,
  });

  final String id;
  final List<Horse> horses;
  final String status;
}
