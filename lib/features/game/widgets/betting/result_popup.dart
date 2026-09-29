// DEV 3 Scope: Betting & Game Loop UI
import 'package:flutter/material.dart';

import '../../../../models/horse.dart';
import '../../data/bet_models.dart';
import 'money_format.dart';

/// Popup BET_RESULT: WON / LOST + payout (M3-10).
class ResultPopup extends StatelessWidget {
  const ResultPopup({super.key, required this.result, required this.horses});

  final RoundResult result;
  final List<Horse> horses;

  static Future<void> show(
    BuildContext context, {
    required RoundResult result,
    required List<Horse> horses,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => ResultPopup(result: result, horses: horses),
    );
  }

  Horse? _horse(String id) {
    for (final h in horses) {
      if (h.id == id) return h;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final won = result.totalPayout > 0;
    final winner = _horse(result.winnerHorseId);
    final accent = won ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return AlertDialog(
      icon: Icon(won ? Icons.emoji_events : Icons.sentiment_dissatisfied, color: accent, size: 40),
      title: Text(
        won ? 'BẠN THẮNG!' : 'RẤT TIẾC!',
        style: TextStyle(color: accent, fontWeight: FontWeight.w900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ngựa thắng: #${winner?.number ?? '?'} ${winner?.name ?? ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Divider(height: 24),
          for (final r in result.results)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${_horse(r.ticket.horseId)?.number ?? '?'} ${r.ticket.horseName} · ${formatMoney(r.ticket.amount)}',
                    ),
                  ),
                  Text(
                    r.isWon ? '+${formatMoney(r.payout)}' : 'THUA',
                    style: TextStyle(
                      color: r.isWon ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 24),
          Row(
            children: [
              const Expanded(child: Text('Tổng nhận')),
              Text(
                formatMoney(result.totalPayout),
                key: const Key('result-total-payout'),
                style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
