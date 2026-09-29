// DEV 1 Scope: Core Mobile Models
import 'horse.dart';

class Race {
  final String id;
  final List<Horse> horses;
  final String status;

  const Race({
    required this.id,
    required this.horses,
    required this.status,
  });
}
