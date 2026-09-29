enum BetStatus { pending, won, lost, refunded }

BetStatus betStatusFromJson(Object? value) {
  return BetStatus.values.firstWhere(
    (status) => status.name.toUpperCase() == value?.toString().toUpperCase(),
    orElse: () => BetStatus.pending,
  );
}

class BetModel {
  const BetModel({
    required this.id,
    required this.raceId,
    required this.horseId,
    required this.horseName,
    required this.odds,
    required this.amount,
    required this.potentialPayout,
    required this.payout,
    required this.status,
    required this.placedAt,
  });

  factory BetModel.fromJson(Map<String, dynamic> json) {
    return BetModel(
      id: json['id'] as String,
      raceId: json['raceId'] as String,
      horseId: json['horseId'].toString(),
      horseName: json['horseName'] as String,
      odds: (json['odds'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      potentialPayout: (json['potentialPayout'] as num).toDouble(),
      payout: (json['payout'] as num? ?? 0).toDouble(),
      status: betStatusFromJson(json['status']),
      placedAt: DateTime.parse(json['placedAt'] as String),
    );
  }

  final String id;
  final String raceId;
  final String horseId;
  final String horseName;
  final double odds;
  final double amount;
  final double potentialPayout;
  final double payout;
  final BetStatus status;
  final DateTime placedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'raceId': raceId,
        'horseId': horseId,
        'horseName': horseName,
        'odds': odds,
        'amount': amount,
        'potentialPayout': potentialPayout,
        'payout': payout,
        'status': status.name.toUpperCase(),
        'placedAt': placedAt.toUtc().toIso8601String(),
      };

  BetModel copyWith({
    BetStatus? status,
    double? payout,
  }) {
    return BetModel(
      id: id,
      raceId: raceId,
      horseId: horseId,
      horseName: horseName,
      odds: odds,
      amount: amount,
      potentialPayout: potentialPayout,
      payout: payout ?? this.payout,
      status: status ?? this.status,
      placedAt: placedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BetModel &&
          id == other.id &&
          raceId == other.raceId &&
          horseId == other.horseId &&
          horseName == other.horseName &&
          odds == other.odds &&
          amount == other.amount &&
          potentialPayout == other.potentialPayout &&
          payout == other.payout &&
          status == other.status &&
          placedAt == other.placedAt;

  @override
  int get hashCode => Object.hash(
        id,
        raceId,
        horseId,
        horseName,
        odds,
        amount,
        potentialPayout,
        payout,
        status,
        placedAt,
      );
}
