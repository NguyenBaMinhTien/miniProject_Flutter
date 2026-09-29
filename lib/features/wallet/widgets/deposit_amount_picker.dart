// DEV 4 Scope: Widget Chọn số tiền nạp nhanh (M4-02 DepositAmountPicker)
import 'package:flutter/material.dart';
import '../wallet_system.dart';

/// Widget hiển thị danh sách các mốc tiền nạp nhanh dưới dạng các ô Chip chọn lựa
class DepositAmountPicker extends StatelessWidget {
  final List<double> presetAmounts; // Danh sách các mốc tiền cố định
  final double? selectedAmount; // Mốc tiền đang được chọn
  final ValueChanged<double> onAmountSelected; // Callback khi chọn mốc tiền mới

  const DepositAmountPicker({
    super.key,
    this.presetAmounts = WalletSystem.presetDepositAmounts,
    required this.selectedAmount,
    required this.onAmountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, // Khoảng cách ngang giữa các chip
      runSpacing: 8, // Khoảng cách dòng giữa các chip
      children: presetAmounts.map((amount) {
        final isSelected = selectedAmount == amount;
        return ChoiceChip(
          label: Text(
            WalletSystem.formatCompact(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          selectedColor: WalletSystem.primaryColor,
          backgroundColor: Colors.grey.shade200,
          onSelected: (_) => onAmountSelected(amount), // Gọi callback khi chọn
        );
      }).toList(),
    );
  }
}
