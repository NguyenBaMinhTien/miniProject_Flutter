import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.totalBets,
    required this.totalWon,
    required this.totalLost,
    required this.winRate,
  });

  final int totalBets;
  final int totalWon;
  final int totalLost;
  final double winRate;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columnCount = constraints.maxWidth >= 600 ? 4 : 2;
            final totalSpacing = 12 * (columnCount - 1);
            final itemWidth =
                (constraints.maxWidth - totalSpacing) / columnCount;

            return Wrap(
              spacing: 12,
              runSpacing: 20,
              children: [
                _StatMetric(
                  width: itemWidth,
                  icon: Icons.confirmation_number_outlined,
                  label: 'Total Bets',
                  value: '$totalBets',
                ),
                _StatMetric(
                  width: itemWidth,
                  icon: Icons.emoji_events_outlined,
                  label: 'Total Won',
                  value: '$totalWon',
                  color: const Color(0xFF176B37),
                ),
                _StatMetric(
                  width: itemWidth,
                  icon: Icons.close_rounded,
                  label: 'Total Lost',
                  value: '$totalLost',
                  color: Theme.of(context).colorScheme.error,
                ),
                _StatMetric(
                  width: itemWidth,
                  icon: Icons.trending_up_rounded,
                  label: 'Win Rate',
                  value: '${winRate.toStringAsFixed(1)}%',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatMetric extends StatelessWidget {
  const _StatMetric({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final metricColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: width,
      child: Row(
        children: [
          Icon(icon, color: metricColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: metricColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
