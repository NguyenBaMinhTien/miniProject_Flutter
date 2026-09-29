// DEV 3 Scope: Betting & Game Loop UI
import 'package:flutter/material.dart';

import 'money_format.dart';

// TODO(DEV 3): Chuyển sang AppConfig.betAmounts khi DEV 1 xong MBE-02.
const List<int> kBetAmounts = [100, 200, 500, 1000, 2000, 5000, 10000];

class ChipSelector extends StatelessWidget {
  const ChipSelector({
    super.key,
    required this.selectedAmount,
    required this.cash,
    required this.enabled,
    required this.onSelected,
    this.amounts = kBetAmounts,
  });

  final List<int> amounts;
  final int? selectedAmount;
  final int cash;
  final bool enabled;
  final ValueChanged<int> onSelected;

  static const _chipColors = [
    Color(0xFF78909C),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color(0xFF212121),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: amounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final amount = amounts[i];
          final affordable = amount <= cash;
          final selected = amount == selectedAmount;
          final color = _chipColors[i % _chipColors.length];
          return _Chip(
            key: ValueKey('chip-$amount'),
            label: formatChip(amount),
            color: color,
            selected: selected,
            dimmed: !affordable,
            onTap: enabled ? () => onSelected(amount) : null,
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.dimmed,
    this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed || onTap == null ? 0.4 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.amber : Colors.white,
              width: selected ? 4 : 2,
            ),
            boxShadow: selected
                ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.6), blurRadius: 8)]
                : null,
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
