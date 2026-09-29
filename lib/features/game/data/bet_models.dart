// DEV 3 Scope: Bet data used by Betting & Game Loop UI
// TODO(DEV 3): Chuyển sang model của DEV 1 khi lib/models/bet.dart đủ field.

/// Vé cược đã được server xác nhận (BET_CONFIRMED).
class BetTicket {
  final String id;
  final String raceId;
  final String horseId;
  final String horseName;
  final double odds;
  final int amount;
  final int potentialPayout;

  const BetTicket({
    required this.id,
    required this.raceId,
    required this.horseId,
    required this.horseName,
    required this.odds,
    required this.amount,
    required this.potentialPayout,
  });

  /// Parse `data` của event BET_CONFIRMED theo contract mục 13.
  factory BetTicket.fromJson(Map<String, dynamic> json) {
    return BetTicket(
      id: json['id'].toString(),
      raceId: json['raceId'].toString(),
      horseId: json['horseId'].toString(),
      horseName: json['horseName'] as String,
      odds: (json['odds'] as num).toDouble(),
      amount: (json['amount'] as num).toInt(),
      potentialPayout: (json['potentialPayout'] as num).toInt(),
    );
  }
}

enum BetOutcome { won, lost }

/// Kết quả của một vé sau khi race kết thúc (BET_RESULT).
class BetResult {
  final BetTicket ticket;
  final BetOutcome outcome;
  final int payout;

  const BetResult({
    required this.ticket,
    required this.outcome,
    required this.payout,
  });

  bool get isWon => outcome == BetOutcome.won;
}

/// Kết quả của cả vòng đua đối với user hiện tại.
class RoundResult {
  final String raceId;
  final String winnerHorseId;
  final List<BetResult> results;

  const RoundResult({
    required this.raceId,
    required this.winnerHorseId,
    required this.results,
  });

  int get totalBet => results.fold(0, (sum, r) => sum + r.ticket.amount);
  int get totalPayout => results.fold(0, (sum, r) => sum + r.payout);
  bool get hasBets => results.isNotEmpty;
}
