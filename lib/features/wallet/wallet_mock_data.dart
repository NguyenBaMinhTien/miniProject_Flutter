// DEV 4 Scope: Mock Data cho tính năng Ví tiền (Wallet Mock Data)
import 'models/transaction_model.dart';

/// Lớp cung cấp dữ liệu giả lập ban đầu độc lập với Backend
class WalletMockData {
  /// Số dư ban đầu sau khi tính toán các giao dịch mẫu
  static const double initialBalance = 60000.0;

  /// Danh sách 3 giao dịch mẫu chuẩn ban đầu để test giao diện
  static List<TransactionModel> get defaultTransactions => [
    TransactionModel(
      id: 'tx_1',
      userId: 'user_1',
      type: TransactionType.deposit,
      cashDelta: 50000.0,
      cashAfter: 50000.0,
      description: 'Nạp tiền tài khoản mới (Mock)',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TransactionModel(
      id: 'tx_2',
      userId: 'user_1',
      type: TransactionType.bet,
      cashDelta: -10000.0,
      cashAfter: 40000.0,
      description: 'Đặt cược ngựa #2 Bạch Long',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    TransactionModel(
      id: 'tx_3',
      userId: 'user_1',
      type: TransactionType.win,
      cashDelta: 20000.0,
      cashAfter: 60000.0,
      description: 'Thắng cược ngựa #2 Bạch Long (2.0x)',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  /// Giả lập tạo mới một bản ghi giao dịch nạp tiền
  static TransactionModel createDepositTransaction({
    required double amount,
    required double newBalance,
  }) {
    return TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_1',
      type: TransactionType.deposit,
      cashDelta: amount,
      cashAfter: newBalance,
      description: 'Nạp tiền nhanh mô phỏng',
      createdAt: DateTime.now(),
    );
  }

  /// Giả lập tạo mới một bản ghi giao dịch realtime từ WebSocket
  static TransactionModel createRealtimeTransaction({
    required double delta,
    required double newBalance,
    required TransactionType type,
    required String description,
  }) {
    return TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_1',
      type: type,
      cashDelta: delta,
      cashAfter: newBalance,
      description: description,
      createdAt: DateTime.now(),
    );
  }
}
