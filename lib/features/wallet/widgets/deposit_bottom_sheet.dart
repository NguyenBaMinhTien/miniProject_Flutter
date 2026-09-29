// DEV 4 Scope: Modal BottomSheet Nạp tiền có 2 Tab (M4-05 DepositBottomSheet)
import 'package:flutter/material.dart';
import '../wallet_system.dart';
import 'quick_mock_deposit.dart';
import 'vietqr_mock_ui.dart';

/// Modal cuộn từ dưới lên (BottomSheet) cho phép lựa chọn 2 phương thức: "Nạp nhanh" hoặc "QR Mô Phỏng"
class DepositBottomSheet extends StatelessWidget {
  final Future<bool> Function(double amount) onDeposit; // Hàm nạp tiền từ Controller

  const DepositBottomSheet({
    super.key,
    required this.onDeposit,
  });

  /// Hàm tiện ích tĩnh giúp hiển thị BottomSheet từ bất kỳ màn hình nào
  static void show(BuildContext context, Future<bool> Function(double amount) onDeposit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DepositBottomSheet(onDeposit: onDeposit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 phương thức nạp tiền
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),

            // Thanh gạch ngang trang trí ở đầu Modal
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),

            // Thanh Tab lựa chọn giữa 2 phương thức nạp
            const TabBar(
              labelColor: WalletSystem.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: WalletSystem.primaryColor,
              tabs: [
                Tab(text: 'Nạp nhanh'),
                Tab(text: 'QR Mô Phỏng'),
              ],
            ),

            // Nội dung chi tiết của từng Tab
            SizedBox(
              height: 320,
              child: TabBarView(
                children: [
                  // Tab 1: Form Nạp tiền nhanh chọn mốc
                  QuickMockDeposit(onDeposit: onDeposit),

                  // Tab 2: Quét mã QR chuyển khoản mô phỏng (theo WalletSystem.defaultVietQRAmount)
                  VietQRMockUI(
                    amount: WalletSystem.defaultVietQRAmount,
                    onSimulateSuccess: () async {
                      final success = await onDeposit(WalletSystem.defaultVietQRAmount);
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Mô phỏng nạp VietQR ${WalletSystem.formatCurrency(WalletSystem.defaultVietQRAmount)} thành công!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
