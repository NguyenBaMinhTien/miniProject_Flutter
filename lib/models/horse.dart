import 'horse_model.dart';

@Deprecated('Use HorseModel')
class Horse extends HorseModel {
  const Horse({
    required this.id,
    required this.name,
    required this.color,
  }) : super(id: id, name: name, color: color, odds: 1, lane: 0);

  @override
  final String id;
  @override
  final String name;
  @override
  final String color;
}
