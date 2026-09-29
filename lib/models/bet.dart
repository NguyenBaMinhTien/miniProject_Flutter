@Deprecated('Use BetModel')
class Bet {
  const Bet({
    required this.id,
    required this.horseId,
    required this.amount,
  });

  final String id;
  final String horseId;
  final double amount;
}
