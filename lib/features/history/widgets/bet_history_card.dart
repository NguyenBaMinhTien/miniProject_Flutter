import 'package:flutter/material.dart';

enum BetHistoryStatus { pending, won, lost, refunded }

class BetHistoryData {
  const BetHistoryData({
    required this.horseName,
    required this.raceNumber,
    required this.betAmount,
    required this.odds,
    required this.payout,
    required this.status,
    required this.placedAt,
  });

  final String horseName;
  final int raceNumber;
  final double betAmount;
  final double odds;
  final double payout;
  final BetHistoryStatus status;
  final String placedAt;
}

class BetHistoryCard extends StatelessWidget {
  const BetHistoryCard({
    super.key,
    required this.bet,
  });

  final BetHistoryData bet;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(context, bet.status);
    final payoutLabel =
        bet.status == BetHistoryStatus.pending ? 'Potential payout' : 'Payout';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.flag_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bet.horseName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Race ${bet.raceNumber}  •  ${bet.placedAt}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: 'Bet status ${statusStyle.label}',
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusStyle.backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusStyle.icon,
                          size: 15,
                          color: statusStyle.foregroundColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusStyle.label,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: statusStyle.foregroundColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Wrap(
              spacing: 24,
              runSpacing: 14,
              children: [
                _BetDetail(
                  label: 'Bet amount',
                  value: _currency(bet.betAmount),
                ),
                _BetDetail(
                  label: 'Odds',
                  value: '${bet.odds.toStringAsFixed(1)}x',
                ),
                _BetDetail(
                  label: payoutLabel,
                  value: _currency(bet.payout),
                  highlight: bet.status == BetHistoryStatus.won,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';

  _BetStatusStyle _statusStyle(
    BuildContext context,
    BetHistoryStatus status,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status) {
      case BetHistoryStatus.pending:
        return const _BetStatusStyle(
          label: 'PENDING',
          icon: Icons.schedule_rounded,
          backgroundColor: Color(0xFFFFF3CD),
          foregroundColor: Color(0xFF795A00),
        );
      case BetHistoryStatus.won:
        return const _BetStatusStyle(
          label: 'WON',
          icon: Icons.emoji_events_rounded,
          backgroundColor: Color(0xFFDFF4E5),
          foregroundColor: Color(0xFF176B37),
        );
      case BetHistoryStatus.lost:
        return _BetStatusStyle(
          label: 'LOST',
          icon: Icons.close_rounded,
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        );
      case BetHistoryStatus.refunded:
        return const _BetStatusStyle(
          label: 'REFUNDED',
          icon: Icons.replay_rounded,
          backgroundColor: Color(0xFFE4ECF5),
          foregroundColor: Color(0xFF36546F),
        );
    }
  }
}

class _BetDetail extends StatelessWidget {
  const _BetDetail({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: highlight ? const Color(0xFF176B37) : null,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _BetStatusStyle {
  const _BetStatusStyle({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
}
