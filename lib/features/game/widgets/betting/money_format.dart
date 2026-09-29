// DEV 3 Scope: Betting & Game Loop UI

/// 2000 → "2,000đ"
String formatMoney(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer(amount < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '$bufferđ';
}

/// 1000 → "1K", 10000 → "10K", 500 → "500"
String formatChip(int amount) =>
    amount >= 1000 && amount % 1000 == 0 ? '${amount ~/ 1000}K' : '$amount';

/// 3.0 → "3.0x", 5.5 → "5.5x"
String formatOdds(double odds) => '${odds.toStringAsFixed(1)}x';
