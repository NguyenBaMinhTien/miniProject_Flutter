// DEV 3 Scope: Betting & Game Loop UI
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/game_controller.dart';
import '../data/mock_game_controller.dart';
import '../data/wallet_cash_source.dart';
import '../widgets/betting/betting_panel.dart';
import '../widgets/betting/money_format.dart';
import '../widgets/betting/my_bets_overlay.dart';
import '../widgets/betting/race_cancelled_dialog.dart';
import '../widgets/betting/result_popup.dart';
import '../widgets/countdown/countdown_timer.dart';
import '../widgets/countdown/phase_banner.dart';
import '../widgets/track/models/race_phase.dart';
import '../widgets/track/race_track_system.dart';
import '../widgets/track/race_track_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.controller, this.wallet})
    : assert(
        (controller == null) == (wallet == null),
        'Truyền cả controller và wallet, hoặc không truyền cái nào.',
      );

  /// Truyền vào khi test. Mặc định dùng MockGameController.
  final GameController? controller;

  /// Nguồn số dư (WalletProvider.cash). Mặc định dùng MockWalletProvider.
  final WalletCashSource? wallet;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // TODO(DEV 3): Đổi sang GameController dùng GameProvider + SocketService của DEV 1,
  // và wallet = WalletProviderCashSource(WalletProvider) (xem wallet_cash_source.dart).
  late final bool _ownsDeps = widget.controller == null;
  late final WalletCashSource _wallet = widget.wallet ?? MockWalletProvider();
  late final GameController _controller =
      widget.controller ?? MockGameController(wallet: _wallet as MockWalletProvider);
  StreamSubscription<GameEvent>? _eventSub;
  RacePhase? _lastPhase;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _eventSub = _controller.events.listen(_onEvent);
    _controller.addListener(_onStateChanged);
    _controller.start();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _controller.removeListener(_onStateChanged);
    if (_ownsDeps) {
      _controller.dispose();
      (_wallet as MockWalletProvider).dispose();
    }
    super.dispose();
  }

  /// Sang vòng mới thì tự đóng popup của vòng trước.
  void _onStateChanged() {
    final phase = _controller.phase;
    if (phase == RacePhase.betting && _lastPhase != RacePhase.betting && _dialogOpen) {
      Navigator.of(context).pop();
    }
    _lastPhase = phase;
  }

  void _onEvent(GameEvent event) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    switch (event) {
      case BetConfirmedEvent(:final ticket):
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            backgroundColor: const Color(0xFF2E7D32),
            content: Text('Đặt cược thành công: ${ticket.horseName} · ${formatMoney(ticket.amount)}'),
          ));
      case BetErrorEvent(:final message):
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            backgroundColor: const Color(0xFFC62828),
            content: Text(message),
          ));
      case BetResultEvent(:final result):
        if (!result.hasBets) return;
        // Đợi WinnerCelebration của DEV 2 chạy xong rồi mới hiện popup.
        Future.delayed(RaceTrackSystem.winnerDuration, () {
          if (!mounted || _controller.phase != RacePhase.finished) return;
          _showDialog(() => ResultPopup.show(context, result: result, horses: _controller.horses));
        });
      case RaceCancelledEvent(:final refundedAmount):
        _showDialog(() => RaceCancelledDialog.show(context, refundedAmount: refundedAmount));
    }
  }

  Future<void> _showDialog(Future<void> Function() show) async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    await show();
    _dialogOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, _wallet]),
      builder: (context, _) {
        final c = _controller;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Đua Ngựa'),
            actions: [
              _CashChip(cash: _wallet.cash),
              if (kDebugMode && c is MockGameController)
                IconButton(
                  tooltip: 'Giả lập hủy phiên',
                  icon: const Icon(Icons.bug_report_outlined),
                  onPressed: c.phase == RacePhase.betting ? c.debugCancelRace : null,
                ),
            ],
          ),
          body: SafeArea(
            child: c.horses.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    children: [
                      // TODO: WinnersTicker (DEV 5, widgets/leaderboard) đặt ở đây.
                      PhaseBanner(phase: c.phase),
                      const SizedBox(height: 8),
                      CountdownTimer(seconds: c.countdown, phase: c.phase),
                      const SizedBox(height: 8),
                      RaceTrackWidget(
                        horses: c.horses,
                        positions: c.positions,
                        phase: c.phase,
                        winnerHorseId: c.winnerHorseId,
                      ),
                      const SizedBox(height: 12),
                      BettingPanelWidget(
                        horses: c.horses,
                        phase: c.phase,
                        cash: _wallet.cash,
                        isPlacingBet: c.isPlacingBet,
                        onPlaceBet: (horseId, amount) =>
                            c.placeBet(horseId: horseId, amount: amount),
                      ),
                      const SizedBox(height: 12),
                      MyBetsOverlay(tickets: c.myBetsThisRound, horses: c.horses),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _CashChip extends StatelessWidget {
  const _CashChip({required this.cash});

  final int cash;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Chip(
        key: const Key('cash-chip'),
        avatar: const Icon(Icons.account_balance_wallet, size: 18),
        label: Text(formatMoney(cash), style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
