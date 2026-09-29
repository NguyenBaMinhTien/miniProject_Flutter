import 'package:flutter/material.dart';
import 'package:flutter_horse_racing/features/game/data/bet_models.dart';
import 'package:flutter_horse_racing/features/game/widgets/betting/bet_confirm_button.dart';
import 'package:flutter_horse_racing/features/game/widgets/betting/betting_panel.dart';
import 'package:flutter_horse_racing/features/game/widgets/betting/money_format.dart';
import 'package:flutter_horse_racing/features/game/widgets/betting/my_bets_overlay.dart';
import 'package:flutter_horse_racing/features/game/widgets/countdown/countdown_timer.dart';
import 'package:flutter_horse_racing/features/game/widgets/countdown/phase_banner.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/models/race_phase.dart';
import 'package:flutter_horse_racing/models/horse.dart';
import 'package:flutter_test/flutter_test.dart';

const _horses = [
  Horse(id: '1', number: 1, name: 'Xích Thố', odds: 2.2, color: 'red'),
  Horse(id: '2', number: 2, name: 'Bạch Long', odds: 3.0, color: 'blue'),
  Horse(id: '3', number: 3, name: 'Kim Quy', odds: 4.0, color: 'gold'),
  Horse(id: '4', number: 4, name: 'Hắc Báo', odds: 5.5, color: 'purple'),
  Horse(id: '5', number: 5, name: 'Thanh Long', odds: 7.0, color: 'green'),
];

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
);

void main() {
  group('formatters', () {
    test('formatMoney', () {
      expect(formatMoney(0), '0đ');
      expect(formatMoney(2000), '2,000đ');
      expect(formatMoney(1234567), '1,234,567đ');
      expect(formatMoney(-2000), '-2,000đ');
    });
    test('formatChip / formatOdds', () {
      expect(formatChip(500), '500');
      expect(formatChip(10000), '10K');
      expect(formatOdds(3), '3.0x');
    });
  });

  group('BetConfirmButton.validate (M3-06)', () {
    String? v({Horse? horse, int? amount, RacePhase phase = RacePhase.betting, int cash = 50000}) =>
        BetConfirmButton.validate(horse: horse, amount: amount, phase: phase, cash: cash);

    test('chưa chọn ngựa', () => expect(v(amount: 100), isNotNull));
    test('chưa chọn amount', () => expect(v(horse: _horses[0]), isNotNull));
    test('không đủ số dư', () => expect(v(horse: _horses[0], amount: 5000, cash: 1000), 'Số dư không đủ'));
    test('sai phase', () {
      for (final p in [RacePhase.racing, RacePhase.finished, RacePhase.cancelled]) {
        expect(v(horse: _horses[0], amount: 100, phase: p), 'Đã khóa cược');
      }
    });
    test('hợp lệ', () => expect(v(horse: _horses[0], amount: 5000, cash: 5000), isNull));
  });

  testWidgets('BettingPanel: chọn ngựa + chip rồi đặt cược', (tester) async {
    String? placedHorse;
    int? placedAmount;
    await tester.pumpWidget(_wrap(BettingPanelWidget(
      horses: _horses,
      phase: RacePhase.betting,
      cash: 50000,
      isPlacingBet: false,
      onPlaceBet: (h, a) {
        placedHorse = h;
        placedAmount = a;
      },
    )));

    final button = find.byKey(const Key('bet-confirm-button'));
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    await tester.tap(find.text('Bạch Long'));
    await tester.tap(find.byKey(const ValueKey('chip-2000')));
    await tester.pump();

    expect(find.textContaining('ĐẶT 2,000đ'), findsOneWidget);
    await tester.tap(button);
    expect(placedHorse, '2');
    expect(placedAmount, 2000);
  });

  testWidgets('BettingPanel không overflow trên phone nhỏ 360px', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_wrap(BettingPanelWidget(
      horses: _horses,
      phase: RacePhase.betting,
      cash: 50000,
      isPlacingBet: false,
      onPlaceBet: (_, __) {},
    )));
    await tester.tap(find.text('Thanh Long'));
    await tester.tap(find.byKey(const ValueKey('chip-1000')));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('BettingPanel: RACING ẩn chip + nút cược', (tester) async {
    await tester.pumpWidget(_wrap(BettingPanelWidget(
      horses: _horses,
      phase: RacePhase.racing,
      cash: 50000,
      isPlacingBet: false,
      onPlaceBet: (_, __) {},
    )));
    expect(find.byKey(const ValueKey('chip-100')), findsNothing);
    expect(find.byKey(const Key('bet-confirm-button')), findsNothing);
    expect(find.text('Xích Thố'), findsOneWidget);
  });

  testWidgets('PhaseBanner + CountdownTimer', (tester) async {
    await tester.pumpWidget(_wrap(const Column(children: [
      PhaseBanner(phase: RacePhase.betting),
      CountdownTimer(seconds: 12, phase: RacePhase.betting),
    ])));
    expect(find.text('ĐANG MỞ CƯỢC'), findsOneWidget);
    expect(find.text('12s'), findsOneWidget);
  });

  testWidgets('MyBetsOverlay hiển thị potential', (tester) async {
    const ticket = BetTicket(
      id: 'b1', raceId: 'r1', horseId: '2', horseName: 'Bạch Long',
      odds: 3.0, amount: 2000, potentialPayout: 6000,
    );
    await tester.pumpWidget(_wrap(const MyBetsOverlay(tickets: [ticket], horses: _horses)));
    expect(find.text('#2 Bạch Long'), findsOneWidget);
    expect(find.text('6,000đ'), findsOneWidget);
  });
}
