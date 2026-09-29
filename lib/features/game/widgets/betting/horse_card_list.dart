// DEV 3 Scope: Betting & Game Loop UI
import 'package:flutter/material.dart';

import '../../../../models/horse.dart';
import 'horse_bet_card.dart';

class HorseCardList extends StatelessWidget {
  const HorseCardList({
    super.key,
    required this.horses,
    required this.selectedHorseId,
    required this.enabled,
    required this.onSelected,
  });

  final List<Horse> horses;
  final String? selectedHorseId;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < horses.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: HorseBetCard(
              key: ValueKey('horse-card-${horses[i].id}'),
              horse: horses[i],
              selected: horses[i].id == selectedHorseId,
              disabled: !enabled,
              onTap: () => onSelected(horses[i].id),
            ),
          ),
        ],
      ],
    );
  }
}
