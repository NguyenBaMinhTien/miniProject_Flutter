// DEV 4 Scope: Form Nạp tiền nhanh mô phỏng (M4-03 QuickMockDeposit)
import 'package:flutter/material.dart';
import 'deposit_amount_picker.dart';

/// Widget giao diện Nạp tiền nhanh với ô chọn mốc tiền và nút xác nhận "NẠP NGAY"
class QuickMockDeposit extends StatefulWidget {
  final Future<bool> Function(double amount) onDeposit; // Hàm thực thi nạp tiền từ Controller

  const QuickMockDeposit({
    super.key,
    required this.onDeposit,
  });

  @override
  State<QuickMockDeposit> createState() => _QuickMockDepositState();
}

class _QuickMockDepositState extends State<QuickMockDeposit> {
  double _selectedAmount = 50000; // Số tiền mặc định ban đầu là 50,000đ
  bool _isLoading = false; // Trạng thái hiệu ứng loading khi bấm nạp

  /// Xử lý sự kiện khi người dùng nhấn nút "NẠP NGAY"
  Future<void> _handleDeposit() async {
    setState(() => _isLoading = true);
    final success = await widget.onDeposit(_selectedAmount);
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Thông báo SnackBAR thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nạp thành công ${_selectedAmount.toInt()} đ vào tài khoản!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Đóng BottomSheet sau khi nạp xong
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn số tiền nạp nhanh (Mock):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Component chọn mốc tiền nạp
          DepositAmountPicker(
            selectedAmount: _selectedAmount,
            onAmountSelected: (amount) {
              setState(() => _selectedAmount = amount);
            },
          ),
          const SizedBox(height: 24),

          // Nút xác nhận NẠP NGAY
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleDeposit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'NẠP NGAY',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
