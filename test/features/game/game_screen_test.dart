import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_horse_racing/features/game/data/mock_game_controller.dart';
import 'package:flutter_horse_racing/features/game/data/wallet_cash_source.dart';
import 'package:flutter_horse_racing/features/game/screens/game_screen.dart';
import 'package:flutter_horse_racing/features/game/widgets/betting/race_cancelled_dialog.dart';
import 'package:flutter_horse_racing/features/game/widgets/betting/result_popup.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/models/race_phase.dart';
import 'package:flutter_test/flutter_test.dart';

MockGameController _fastController() => MockGameController(
  wallet: MockWalletProvider(),
  bettingSeconds: 5,
  finishedSeconds: 8,
  cancelledSeconds: 5,
  random: Random(7),
);

Future<void> _pumpApp(WidgetTester tester, MockGameController c) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: GameScreen(controller: c, wallet: c.wallet)));
  await tester.pump(const Duration(milliseconds: 400)); // load horses
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 400 && !done(); i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(done(), isTrue);
}

void main() {
  testWidgets('E2E mock: chọn ngựa → PLACE_BET → RACING → FINISHED → ResultPopup',
      (tester) async {
    final c = _fastController();
    await _pumpApp(tester, c);

    expect(find.text('ĐANG MỞ CƯỢC'), findsOneWidget);
    expect(find.text('50,000đ'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('horse-card-2')));
    await tester.tap(find.byKey(const ValueKey('chip-2000')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('bet-confirm-button')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Đặt cược thành công'), findsOneWidget);
    expect(find.text('48,000đ'), findsOneWidget);
    expect(find.text('#2 Bạch Long'), findsOneWidget);

    await _pumpUntil(tester, () => c.phase == RacePhase.racing);
    await tester.pump();
    expect(find.text('ĐANG ĐUA'), findsOneWidget);
    expect(find.byKey(const Key('bet-confirm-button')), findsNothing);

    await _pumpUntil(tester, () => c.phase == RacePhase.finished);
    await tester.pump(const Duration(seconds: 3, milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ResultPopup), findsOneWidget);

    // Vòng mới tự đóng popup.
    await _pumpUntil(tester, () => c.phase == RacePhase.betting);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ResultPopup), findsNothing);
    expect(tester.takeException(), isNull);
    c.dispose();
  });

  testWidgets('CANCELLED: hiện dialog và hoàn tiền', (tester) async {
    final c = _fastController();
    await _pumpApp(tester, c);

    await tester.tap(find.byKey(const ValueKey('horse-card-1')));
    await tester.tap(find.byKey(const ValueKey('chip-5000')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('bet-confirm-button')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('45,000đ'), findsOneWidget);

    c.debugCancelRace();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(RaceCancelledDialog), findsOneWidget);
    expect(find.text('Phiên đã bị hủy.'), findsOneWidget);
    expect(find.text('ĐÃ HỦY'), findsOneWidget);
    expect(find.text('50,000đ'), findsOneWidget);
    await _pumpUntil(tester, () => c.phase == RacePhase.betting);
    c.dispose();
  });

  testWidgets('Số dư đọc từ wallet: đổi từ bên ngoài (vd nạp tiền) thì GameScreen cập nhật',
      (tester) async {
    final c = _fastController();
    await _pumpApp(tester, c);
    expect(find.text('50,000đ'), findsOneWidget);

    c.wallet.applyBalanceUpdate(1500); // BALANCE_UPDATE không đến từ game
    await tester.pump();
    expect(find.text('1,500đ'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('horse-card-1')));
    await tester.tap(find.byKey(const ValueKey('chip-2000')));
    await tester.pump();
    expect(find.text('Số dư không đủ'), findsOneWidget);
    c.dispose();
  });
}
