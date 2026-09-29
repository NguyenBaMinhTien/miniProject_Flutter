// DEV 3 Scope: Betting & Game Loop UI
import 'package:flutter/material.dart';

import '../../../../models/horse.dart';
import '../track/race_track_system.dart';
import 'money_format.dart';

class HorseBetCard extends StatelessWidget {
  const HorseBetCard({
    super.key,
    required this.horse,
    required this.selected,
    required this.disabled,
    this.onTap,
  });

  final Horse horse;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = RaceTrackSystem.parseHorseColor(
      horse.color,
      fallbackIndex: horse.number - 1,
    );
    final scheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: disabled && !selected ? 0.45 : 1,
      child: Material(
        color: selected ? color.withValues(alpha: 0.15) : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? color : scheme.outlineVariant,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color,
                  child: Text(
                    '${horse.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 32,
                  child: Center(
                    child: Text(
                      horse.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatOdds(horse.odds),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
