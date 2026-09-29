// DEV 4 Scope: Widget Thẻ hiển thị số dư khả dụng (M4-01 BalanceCard)
import 'package:flutter/material.dart';
import '../wallet_system.dart';

/// Component Widget hiển thị thẻ Ví tiền với Gradient màu sắc hiện đại và Nút Nạp tiền
class BalanceCard extends StatelessWidget {
  final double cash; // Số dư khả dụng truyền từ Controller
  final VoidCallback onDepositPressed; // Callback khi bấm nút Nạp tiền

  const BalanceCard({
    super.key,
    required this.cash,
    required this.onDepositPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: WalletSystem.balanceCardGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề Thẻ Ví
            const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  'Số dư khả dụng',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hiển thị số tiền khả dụng format qua WalletSystem
            Text(
              WalletSystem.formatCurrency(cash),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Nút bấm kích hoạt Modal Nạp tiền mô phỏng
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDepositPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WalletSystem.accentColor,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                  'NẠP TIỀN MÔ PHỎNG',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
