import 'dart:math';

import 'package:flutter_horse_racing/features/game/data/game_controller.dart';
import 'package:flutter_horse_racing/features/game/data/mock_game_controller.dart';
import 'package:flutter_horse_racing/features/game/data/wallet_cash_source.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/models/race_phase.dart';
import 'package:flutter_test/flutter_test.dart';

MockGameController _controller({int bettingSeconds = 50}) => MockGameController(
  wallet: MockWalletProvider(),
  bettingSeconds: bettingSeconds,
  finishedSeconds: 50,
  cancelledSeconds: 50,
  secondDuration: const Duration(milliseconds: 10),
  tickDuration: const Duration(milliseconds: 1),
  networkDelay: Duration.zero,
  random: Random(42),
);

Future<void> _waitFor(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) fail('Timed out waiting');
    await Future.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  test('starts in BETTING with 5 horses from repository', () async {
    final c = _controller();
    await c.start();
    expect(c.phase, RacePhase.betting);
    expect(c.horses, hasLength(5));
    expect(c.horses.first.odds, 2.2);
    expect(c.positions, everyElement(0));
    c.dispose();
  });

  test('PLACE_BET success deducts cash and adds ticket', () async {
    final c = _controller();
    final events = <GameEvent>[];
    c.events.listen(events.add);
    await c.start();

    await c.placeBet(horseId: '2', amount: 2000);
    await Future.delayed(Duration.zero);

    expect(c.wallet.cash, 48000);
    expect(c.myBetsThisRound.single.potentialPayout, 6000);
    expect(events.single, isA<BetConfirmedEvent>());
    c.dispose();
  });

  test('PLACE_BET rejects insufficient balance and invalid amount', () async {
    final c = MockGameController(
      wallet: MockWalletProvider(initialCash: 500),
      networkDelay: Duration.zero,
    );
    final events = <GameEvent>[];
    c.events.listen(events.add);
    await c.start();

    await c.placeBet(horseId: '1', amount: 1000);
    await c.placeBet(horseId: '1', amount: 50);
    await Future.delayed(Duration.zero);

    expect(c.wallet.cash, 500);
    expect(c.myBetsThisRound, isEmpty);
    expect(events, everyElement(isA<BetErrorEvent>()));
    expect(events, hasLength(2));
    c.dispose();
  });

  test('full loop: BETTING → RACING → FINISHED settles bets', () async {
    final c = _controller(bettingSeconds: 3);
    final events = <GameEvent>[];
    c.events.listen(events.add);
    await c.start();
    for (final h in c.horses) {
      await c.placeBet(horseId: h.id, amount: 1000);
    }

    await _waitFor(() => c.phase == RacePhase.racing);
    await c.placeBet(horseId: '1', amount: 1000);
    await _waitFor(() => c.phase == RacePhase.finished);
    await Future.delayed(Duration.zero);

    final result = c.lastBetResult!;
    final winner = c.horses.firstWhere((h) => h.id == c.winnerHorseId);
    expect(c.positions.reduce(max), 100);
    expect(result.results.where((r) => r.isWon).single.ticket.horseId, winner.id);
    expect(c.wallet.cash, 50000 - 5000 + (1000 * winner.odds).round());
    expect(events.whereType<BetErrorEvent>(), hasLength(1)); // bet trong RACING bị từ chối
    expect(events.last, isA<BetResultEvent>());
    c.dispose();
  });

  test('CANCELLED refunds 100% and returns to BETTING', () async {
    final c = MockGameController(
      wallet: MockWalletProvider(),
      cancelledSeconds: 2,
      secondDuration: const Duration(milliseconds: 10),
      networkDelay: Duration.zero,
    );
    final events = <GameEvent>[];
    c.events.listen(events.add);
    await c.start();
    await c.placeBet(horseId: '3', amount: 5000);

    c.debugCancelRace();
    await Future.delayed(Duration.zero);
    expect(c.phase, RacePhase.cancelled);
    expect(c.wallet.cash, 50000);
    expect((events.last as RaceCancelledEvent).refundedAmount, 5000);

    await _waitFor(() => c.phase == RacePhase.betting);
    expect(c.myBetsThisRound, isEmpty);
    c.dispose();
  });
}
