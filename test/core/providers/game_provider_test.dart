import 'package:flutter_horse_racing/core/providers/game_provider.dart';
import 'package:flutter_horse_racing/core/socket/mock_socket_service.dart';
import 'package:flutter_horse_racing/core/socket/socket_event.dart';
import 'package:flutter_horse_racing/models/bet_model.dart';
import 'package:flutter_horse_racing/models/race_state_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initial state is safe for mock-first UI', () async {
    final socket = MockSocketService();
    final provider = GameProvider(socketService: socket);

    expect(provider.raceState, isNull);
    expect(provider.phase, RacePhase.waiting);
    expect(provider.countdown, 0);
    expect(provider.positions, isEmpty);
    expect(provider.myBetsThisRound, isEmpty);
    expect(provider.lastBetResult, isNull);
    expect(provider.error, isNull);

    provider.dispose();
    await socket.dispose();
  });

  test('race state, countdown, and ticks update game state', () async {
    final socket = MockSocketService();
    final provider = GameProvider(socketService: socket);

    socket.emit(
        SocketEvent(type: SocketEventType.raceState, data: racePayload()));
    socket.emit(
      const SocketEvent(
        type: SocketEventType.countdown,
        data: {'countdown': 7},
      ),
    );
    socket.emit(
      const SocketEvent(
        type: SocketEventType.raceTick,
        data: {
          'positions': {'horse_1': 25, 'horse_2': 30.5},
        },
      ),
    );
    await pumpEventQueue();

    expect(provider.raceState?.raceId, 'race_1');
    expect(provider.phase, RacePhase.betting);
    expect(provider.countdown, 7);
    expect(provider.positions, {'horse_1': 25.0, 'horse_2': 30.5});

    provider.dispose();
    await socket.dispose();
  });

  test('bet confirmation and result update current-round bets', () async {
    final socket = MockSocketService();
    final provider = GameProvider(socketService: socket);
    socket.emit(
      SocketEvent(
        type: SocketEventType.betConfirmed,
        data: betPayload(status: 'PENDING'),
      ),
    );
    socket.emit(
      SocketEvent(
        type: SocketEventType.betResult,
        data: betPayload(status: 'WON', payout: 6000),
      ),
    );
    await pumpEventQueue();

    expect(provider.myBetsThisRound, hasLength(1));
    expect(provider.myBetsThisRound.single.status, BetStatus.won);
    expect(provider.lastBetResult?.status, BetStatus.won);
    expect(provider.lastBetResult?.payout, 6000);

    provider.clearLastBetResult();
    expect(provider.lastBetResult, isNull);
    provider.dispose();
    await socket.dispose();
  });

  test('cancellation and refund update phase and matching bet', () async {
    final socket = MockSocketService();
    final provider = GameProvider(socketService: socket);
    socket.emit(
        SocketEvent(type: SocketEventType.raceState, data: racePayload()));
    socket.emit(
      SocketEvent(
        type: SocketEventType.betConfirmed,
        data: betPayload(status: 'PENDING'),
      ),
    );
    socket.emit(
      const SocketEvent(type: SocketEventType.raceCancelled, data: {}),
    );
    socket.emit(
      SocketEvent(
        type: SocketEventType.betRefunded,
        data: betPayload(status: 'REFUNDED', payout: 2000),
      ),
    );
    await pumpEventQueue();

    expect(provider.phase, RacePhase.cancelled);
    expect(provider.myBetsThisRound.single.status, BetStatus.refunded);
    expect(provider.myBetsThisRound.single.payout, 2000);

    provider.dispose();
    await socket.dispose();
  });

  test('invalid event payload exposes error and stream remains usable',
      () async {
    final socket = MockSocketService();
    final provider = GameProvider(socketService: socket);
    socket.emit(
      const SocketEvent(
        type: SocketEventType.countdown,
        data: {'countdown': 'bad'},
      ),
    );
    socket.emit(
      const SocketEvent(
        type: SocketEventType.countdown,
        data: {'countdown': 3},
      ),
    );
    await pumpEventQueue();

    expect(provider.error, contains('COUNTDOWN'));
    expect(provider.countdown, 3);

    provider.dispose();
    await socket.dispose();
  });

  test('placeBet sends exact values through socket service', () async {
    final socket = MockSocketService();
    await socket.connect();
    final provider = GameProvider(socketService: socket);

    provider.placeBet(raceId: 'race_9', horseId: 'horse_4', amount: 500);
    await pumpEventQueue();

    expect(provider.myBetsThisRound, hasLength(1));
    expect(provider.myBetsThisRound.single.raceId, 'race_9');
    expect(provider.myBetsThisRound.single.horseId, 'horse_4');
    expect(provider.myBetsThisRound.single.amount, 500);

    provider.dispose();
    await socket.dispose();
  });
}

Map<String, dynamic> racePayload() => {
      'raceId': 'race_1',
      'raceNumber': 1,
      'phase': 'BETTING',
      'countdown': 15,
      'horses': [
        {
          'id': 'horse_1',
          'name': 'Xich Tho',
          'color': 'red',
          'odds': 2.0,
          'lane': 1,
        },
        {
          'id': 'horse_2',
          'name': 'Bach Long',
          'color': 'blue',
          'odds': 3.0,
          'lane': 2,
        },
      ],
      'positions': {'horse_1': 0, 'horse_2': 0},
      'winnerId': null,
    };

Map<String, dynamic> betPayload({required String status, double payout = 0}) =>
    {
      'id': 'bet_1',
      'raceId': 'race_1',
      'horseId': 'horse_2',
      'horseName': 'Bach Long',
      'odds': 3.0,
      'amount': 2000,
      'potentialPayout': 6000,
      'payout': payout,
      'status': status,
      'placedAt': '2026-09-29T10:00:00.000Z',
    };
