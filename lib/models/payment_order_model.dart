class PaymentOrderModel {
  const PaymentOrderModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.qrCode,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      qrCode: json['qrCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final double amount;
  final String status;
  final String? qrCode;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'status': status,
        if (qrCode != null) 'qrCode': qrCode,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentOrderModel &&
          id == other.id &&
          amount == other.amount &&
          status == other.status &&
          qrCode == other.qrCode &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, amount, status, qrCode, createdAt);
}
