// DEV 4 Scope: Giao diện Quét QR mô phỏng (M4-04 VietQRMockUI)
import 'package:flutter/material.dart';

/// Widget hiển thị Mã QR mô phỏng cho trải nghiệm Demo UX nạp tiền qua ngân hàng
class VietQRMockUI extends StatelessWidget {
  final double amount; // Số tiền tương ứng trên mã QR
  final VoidCallback onSimulateSuccess; // Callback mô phỏng người dùng đã quét và chuyển khoản thành công

  const VietQRMockUI({
    super.key,
    required this.amount,
    required this.onSimulateSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quét mã QR Mô Phỏng VietQR',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),

          // Khuyên đọc: Mô phỏng UI/UX demo
          const Text(
            'Chỉ dùng để demo UI/UX. Không thực hiện giao dịch ngân hàng thật.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 10),

          // Khung chứa hình ảnh Mã QR mô phỏng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_2,
                  size: 90,
                  color: Colors.indigo.shade900,
                ),
                const SizedBox(height: 4),
                Text(
                  'Số tiền: ${amount.toInt()} đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Nút bấm giả lập sự kiện ngân hàng báo chuyển khoản thành công
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSimulateSuccess,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: Colors.green, width: 1.5),
              ),
              icon: const Icon(Icons.check_circle, color: Colors.green),
              label: const Text(
                'Mô phỏng quét QR thành công',
                style: TextStyle(
                  color: Colors.green,
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
