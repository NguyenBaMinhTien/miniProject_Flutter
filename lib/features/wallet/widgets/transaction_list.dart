// DEV 4 Scope: Widget Danh sách Lịch sử Giao dịch Ví (M4-06 TransactionList)
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../wallet_system.dart';

/// Widget dạng ListView hiển thị danh sách các bản ghi lịch sử giao dịch phát sinh
class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions; // Danh sách giao dịch từ Controller

  const TransactionList({
    super.key,
    required this.transactions,
  });

  /// Hàm định dạng thời gian ngày/tháng/năm giờ:phút
  String _formatDate(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.day}/${dt.month}/${dt.year}';
  }

  /// Hàm trả về Icon đại diện cho từng loại giao dịch
  IconData _getIcon(TransactionType type) {
    switch (type) {
      case TransactionType.bet:
        return Icons.sports_score; // Đặt cược
      case TransactionType.win:
        return Icons.emoji_events; // Cúp thắng cược
      case TransactionType.refund:
        return Icons.replay; // Hoàn tiền
      case TransactionType.deposit:
        return Icons.add_card; // Nạp tiền
      case TransactionType.adminAdjust:
        return Icons.tune; // Điều chỉnh
    }
  }

  /// Trả về màu sắc hiển thị theo Design Tokens của WalletSystem
  Color _getColor(double delta) {
    if (delta > 0) return WalletSystem.positiveColor;
    if (delta < 0) return WalletSystem.negativeColor;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    // Trạng thái danh sách rỗng (Empty State)
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Chưa có giao dịch nào',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Hiển thị danh sách các item giao dịch
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Để cuộn cùng trang cha
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isPositive = tx.cashDelta >= 0;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

          // Icon đại diện bên trái với vòng tròn màu mền tương ứng
          leading: CircleAvatar(
            backgroundColor: isPositive ? Colors.green.shade50 : Colors.red.shade50,
            child: Icon(
              _getIcon(tx.type),
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),

          // Tiêu đề: Mô tả giao dịch
          title: Text(
            tx.description,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),

          // Phụ đề: Loại giao dịch + Thời gian khởi tạo
          subtitle: Text(
            '${tx.type.label} • ${_formatDate(tx.createdAt)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          // Bên phải: Số tiền biến động (+ / -) dùng hàm formatDelta của WalletSystem
          trailing: Text(
            WalletSystem.formatDelta(tx.cashDelta),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: _getColor(tx.cashDelta),
            ),
          ),
        );
      },
    );
  }
}
