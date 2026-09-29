// DEV 3 Scope: Betting & Game Loop UI
import 'package:flutter/material.dart';

import '../../../../models/horse.dart';
import '../track/models/race_phase.dart';
import 'money_format.dart';

class BetConfirmButton extends StatelessWidget {
  const BetConfirmButton({
    super.key,
    required this.selectedHorse,
    required this.selectedAmount,
    required this.phase,
    required this.cash,
    required this.isLoading,
    required this.onPressed,
  });

  final Horse? selectedHorse;
  final int? selectedAmount;
  final RacePhase phase;
  final int cash;
  final bool isLoading;
  final VoidCallback onPressed;

  /// Trả về lý do không cho đặt cược, hoặc null nếu hợp lệ (M3-06).
  static String? validate({
    required Horse? horse,
    required int? amount,
    required RacePhase phase,
    required int cash,
  }) {
    if (phase != RacePhase.betting) return 'Đã khóa cược';
    if (horse == null) return 'Chọn ngựa để đặt cược';
    if (amount == null) return 'Chọn mức cược';
    if (cash < amount) return 'Số dư không đủ';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final reason = validate(
      horse: selectedHorse,
      amount: selectedAmount,
      phase: phase,
      cash: cash,
    );
    final enabled = reason == null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        key: const Key('bet-confirm-button'),
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                reason ??
                    'ĐẶT ${formatMoney(selectedAmount!)} · #${selectedHorse!.number} ${selectedHorse!.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}
