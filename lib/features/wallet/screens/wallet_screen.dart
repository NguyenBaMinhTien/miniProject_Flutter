// DEV 4 Scope: Màn hình chính Ví tiền & Nạp tiền (M4-07 WalletScreen)
import 'package:flutter/material.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/balance_card.dart';
import '../widgets/deposit_bottom_sheet.dart';
import '../widgets/transaction_list.dart';

/// Màn hình chính của tính năng Ví tiền (Wallet Feature Screen)
class WalletScreen extends StatefulWidget {
  final WalletController? controller; // Cho phép truyền Controller từ bên ngoài (khi test hoặc Provider)

  const WalletScreen({
    super.key,
    this.controller,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final WalletController _controller;

  @override
  void initState() {
    super.initState();
    // Nếu không truyền Controller ngoài thì khởi tạo mới WalletController
    _controller = widget.controller ?? WalletController();
  }

  @override
  void dispose() {
    // Chỉ giải phóng Controller nếu nó được tạo nội bộ trong màn hình này
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ví Tiền & Nạp Mô Phỏng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // Lắng nghe sự thay đổi trạng thái dữ liệu từ WalletController
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // Trạng thái Đang tải dữ liệu ban đầu
          if (_controller.status == WalletStatus.loading &&
              _controller.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Trạng thái Lỗi khi tải dữ liệu
          if (_controller.status == WalletStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    _controller.errorMessage ?? 'Có lỗi xảy ra',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _controller.refresh,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Giao diện chính: Hỗ trợ kéo vuốt làm mới trang (Pull-to-refresh)
          return RefreshIndicator(
            onRefresh: _controller.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Component Thẻ số dư ví + Nút bấm nạp tiền
                  BalanceCard(
                    cash: _controller.cash,
                    onDepositPressed: () {
                      // Kích hoạt Modal Nạp tiền BottomSheet
                      DepositBottomSheet.show(
                        context,
                        _controller.mockDeposit,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // 2. Tiêu đề Lịch sử giao dịch
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lịch sử giao dịch',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. Component Danh sách giao dịch
                  TransactionList(transactions: _controller.transactions),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
