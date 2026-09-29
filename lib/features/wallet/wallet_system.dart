// DEV 4 Scope: System & Design Tokens cho tính năng Ví tiền (Wallet System)
import 'package:flutter/material.dart';

/// Class quản lý toàn bộ Tokens, Hằng số cấu hình và Utilities của Module Ví tiền
class WalletSystem {
  // --- Hằng số nghiệp vụ (Business Constants) ---
  static const double initialMockCash = 50000.0;
  static const double defaultVietQRAmount = 50000.0;
  static const List<double> presetDepositAmounts = [
    10000.0,
    20000.0,
    50000.0,
    100000.0,
    200000.0,
    500000.0,
  ];

  // --- Giả lập thời gian phản hồi mạng (Mock Network Latency) ---
  static const Duration mockNetworkDelay = Duration(milliseconds: 300);
  static const Duration mockRefreshDelay = Duration(milliseconds: 200);

  // --- Design Tokens (Màu sắc, Gradient, Giao diện) ---
  static const LinearGradient balanceCardGradient = LinearGradient(
    colors: [Colors.indigo, Colors.purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color primaryColor = Colors.deepPurple;
  static const Color accentColor = Colors.amber;
  static final Color positiveColor = Colors.green.shade700;
  static final Color negativeColor = Colors.red.shade700;

  // --- Utilities định dạng tiền tệ ---
  /// Định dạng số tiền (Ví dụ: 50000 -> "50,000 đ")
  static String formatCurrency(double amount) {
    final int val = amount.toInt();
    final String str = val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$str đ';
  }

  /// Định dạng biến động số dư có dấu (+/-) (Ví dụ: 20000 -> "+20,000 đ", -10000 -> "-10,000 đ")
  static String formatDelta(double amount) {
    final String sign = amount >= 0 ? '+' : '-';
    final int val = amount.abs().toInt();
    final String str = val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$sign$str đ';
  }

  /// Định dạng rút gọn số tiền (Ví dụ: 50000 -> "50k đ")
  static String formatCompact(double amount) {
    final int val = amount.toInt();
    if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(0)}k đ';
    }
    return '$val đ';
  }
}
