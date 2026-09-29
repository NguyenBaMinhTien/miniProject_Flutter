class HorseModel {
  const HorseModel({
    required this.id,
    required this.name,
    required this.color,
    required this.odds,
    required this.lane,
  });

  factory HorseModel.fromJson(Map<String, dynamic> json) {
    return HorseModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      color: json['color'] as String,
      odds: (json['odds'] as num).toDouble(),
      lane: (json['lane'] as num).toInt(),
    );
  }

  final String id;
  final String name;
  final String color;
  final double odds;
  final int lane;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'odds': odds,
        'lane': lane,
      };

  HorseModel copyWith({
    String? id,
    String? name,
    String? color,
    double? odds,
    int? lane,
  }) {
    return HorseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      odds: odds ?? this.odds,
      lane: lane ?? this.lane,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HorseModel &&
          id == other.id &&
          name == other.name &&
          color == other.color &&
          odds == other.odds &&
          lane == other.lane;

  @override
  int get hashCode => Object.hash(id, name, color, odds, lane);
}
