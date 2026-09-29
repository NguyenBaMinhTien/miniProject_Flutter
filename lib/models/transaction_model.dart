enum TransactionType { bet, win, refund, deposit, unknown }

TransactionType transactionTypeFromJson(Object? value) {
  return TransactionType.values.firstWhere(
    (type) => type.name.toUpperCase() == value?.toString().toUpperCase(),
    orElse: () => TransactionType.unknown,
  );
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.createdAt,
    this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: transactionTypeFromJson(json['type']),
      amount: (json['amount'] as num).toDouble(),
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final TransactionType type;
  final double amount;
  final double balanceAfter;
  final String? description;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name.toUpperCase(),
        'amount': amount,
        'balanceAfter': balanceAfter,
        if (description != null) 'description': description,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          id == other.id &&
          type == other.type &&
          amount == other.amount &&
          balanceAfter == other.balanceAfter &&
          description == other.description &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(id, type, amount, balanceAfter, description, createdAt);
}
