// DEV 3 Scope: Betting & Game Loop UI
import 'package:flutter/material.dart';

import '../../../../models/horse.dart';
import '../track/models/race_phase.dart';
import 'bet_confirm_button.dart';
import 'chip_selector.dart';
import 'horse_card_list.dart';

/// Ghép HorseCardList + ChipSelector + BetConfirmButton.
/// Giữ state cục bộ selectedHorseId / selectedAmount (M3-04).
class BettingPanelWidget extends StatefulWidget {
  const BettingPanelWidget({
    super.key,
    required this.horses,
    required this.phase,
    required this.cash,
    required this.isPlacingBet,
    required this.onPlaceBet,
  });

  final List<Horse> horses;
  final RacePhase phase;
  final int cash;
  final bool isPlacingBet;
  final void Function(String horseId, int amount) onPlaceBet;

  @override
  State<BettingPanelWidget> createState() => _BettingPanelWidgetState();
}

class _BettingPanelWidgetState extends State<BettingPanelWidget> {
  String? _selectedHorseId;
  int? _selectedAmount;

  @override
  void didUpdateWidget(covariant BettingPanelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Vòng mới: bỏ chọn ngựa, giữ lại mức cược quen dùng.
    if (widget.phase == RacePhase.betting && oldWidget.phase != RacePhase.betting) {
      _selectedHorseId = null;
    }
  }

  Horse? get _selectedHorse {
    for (final h in widget.horses) {
      if (h.id == _selectedHorseId) return h;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final canBet = widget.phase == RacePhase.betting;
    // RACING: ẩn ChipSelector và nút cược (M3-13).
    final showBetControls = widget.phase != RacePhase.racing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HorseCardList(
          horses: widget.horses,
          selectedHorseId: _selectedHorseId,
          enabled: canBet,
          onSelected: (id) => setState(() => _selectedHorseId = id),
        ),
        if (showBetControls) ...[
          const SizedBox(height: 12),
          ChipSelector(
            selectedAmount: _selectedAmount,
            cash: widget.cash,
            enabled: canBet,
            onSelected: (amount) => setState(() => _selectedAmount = amount),
          ),
          const SizedBox(height: 12),
          BetConfirmButton(
            selectedHorse: _selectedHorse,
            selectedAmount: _selectedAmount,
            phase: widget.phase,
            cash: widget.cash,
            isLoading: widget.isPlacingBet,
            onPressed: () => widget.onPlaceBet(_selectedHorseId!, _selectedAmount!),
          ),
        ],
      ],
    );
  }
}
