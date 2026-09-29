// DEV 1 Scope: Core Mobile Models
class Horse {
  final String id;
  final int number;
  final String name;
  final double odds;
  final String color;

  const Horse({
    required this.id,
    required this.number,
    required this.name,
    required this.odds,
    required this.color,
  });

  factory Horse.fromJson(Map<String, dynamic> json) {
    return Horse(
      id: json['id'].toString(),
      number: (json['number'] as num).toInt(),
      name: json['name'] as String,
      odds: (json['odds'] as num).toDouble(),
      color: json['color'] as String,
    );
  }
}
