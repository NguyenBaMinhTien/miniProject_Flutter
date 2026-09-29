// DEV 3 Scope: Betting & Game Loop UI
import 'package:flutter/material.dart';

import 'money_format.dart';

/// Dialog RACE_CANCELLED (M3-11).
class RaceCancelledDialog extends StatelessWidget {
  const RaceCancelledDialog({super.key, required this.refundedAmount});

  final int refundedAmount;

  static Future<void> show(BuildContext context, {required int refundedAmount}) {
    return showDialog<void>(
      context: context,
      builder: (_) => RaceCancelledDialog(refundedAmount: refundedAmount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.block, color: Color(0xFFC62828), size: 40),
      title: const Text('Phiên đã bị hủy.'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Tiền cược sẽ được hoàn lại 100%.', textAlign: TextAlign.center),
          if (refundedAmount > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Đã hoàn: ${formatMoney(refundedAmount)}',
              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
            ),
          ],
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đã hiểu'),
        ),
      ],
    );
  }
}
