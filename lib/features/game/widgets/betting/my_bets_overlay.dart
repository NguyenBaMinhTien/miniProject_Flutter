// DEV 3 Scope: Betting & Game Loop UI
import 'package:flutter/material.dart';

import '../../../../models/horse.dart';
import '../../data/bet_models.dart';
import 'money_format.dart';

/// Danh sách vé cược trong vòng hiện tại (M3-09).
class MyBetsOverlay extends StatelessWidget {
  const MyBetsOverlay({
    super.key,
    required this.tickets,
    required this.horses,
  });

  final List<BetTicket> tickets;
  final List<Horse> horses;

  int? _numberOf(String horseId) {
    for (final h in horses) {
      if (h.id == horseId) return h.number;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) return const SizedBox.shrink();
    final totalBet = tickets.fold(0, (sum, t) => sum + t.amount);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        leading: const Icon(Icons.receipt_long),
        title: Text('Vé cược của tôi (${tickets.length})'),
        subtitle: Text('Tổng cược ${formatMoney(totalBet)}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          for (final t in tickets)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${_numberOf(t.horseId) ?? '?'} ${t.horseName}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${formatMoney(t.amount)} · Odds ${formatOdds(t.odds)}',
                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Potential', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11)),
                      Text(
                        formatMoney(t.potentialPayout),
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
