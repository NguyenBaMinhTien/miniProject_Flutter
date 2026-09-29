// DEV 4 Scope: Model quản lý dữ liệu Giao dịch Ví (Transaction Model)

/// Các loại giao dịch phát sinh trong ví
enum TransactionType {
  bet, // Đặt cược đua ngựa
  win, // Thắng cược nhận thưởng
  refund, // Hoàn tiền khi phiên đua bị hủy
  deposit, // Nạp tiền mô phỏng (Mock Deposit)
  adminAdjust, // Admin điều chỉnh số dư
}

/// Extension hỗ trợ hiển thị tên tiếng Việt tương ứng cho từng loại giao dịch
extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.bet:
        return 'Đặt cược';
      case TransactionType.win:
        return 'Thắng cược';
      case TransactionType.refund:
        return 'Hoàn tiền';
      case TransactionType.deposit:
        return 'Nạp tiền (Mock)';
      case TransactionType.adminAdjust:
        return 'Điều chỉnh';
    }
  }
}

/// Model lưu trữ thông tin chi tiết của một giao dịch tài chính
class TransactionModel {
  final String id; // Mã định danh duy nhất của giao dịch
  final String userId; // ID người dùng thực hiện giao dịch
  final TransactionType type; // Loại giao dịch (Nạp/Đặt cược/Thắng/Hoàn tiền)
  final double cashDelta; // Biến động số dư (Dương + là tăng, Âm - là giảm)
  final double cashAfter; // Số dư khả dụng của ví sau khi giao dịch hoàn tất
  final String description; // Mô tả chi tiết giao dịch (Ví dụ: "Thắng cược ngựa #2")
  final DateTime createdAt; // Thời gian khởi tạo giao dịch

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.cashDelta,
    required this.cashAfter,
    required this.description,
    required this.createdAt,
  });
}
