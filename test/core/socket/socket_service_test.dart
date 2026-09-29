import 'dart:async';
import 'dart:convert';

import 'package:flutter_horse_racing/core/socket/live_socket_service.dart';
import 'package:flutter_horse_racing/core/socket/mock_socket_service.dart';
import 'package:flutter_horse_racing/core/socket/socket_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('socket event parses a valid envelope', () {
    final event = SocketEvent.fromMessage(
      jsonEncode({
        'type': 'RACE_TICK',
        'data': {
          'raceId': 'race_1',
          'positions': {'horse_1': 42.5},
        },
      }),
    );

    expect(event.type, SocketEventType.raceTick);
    expect(event.data['raceId'], 'race_1');
    expect(event.data['positions'], {'horse_1': 42.5});
  });

  test('mock events are broadcast to multiple listeners', () async {
    final socket = MockSocketService();
    final first = socket.events.first;
    final second = socket.events.first;

    socket.emit(
      const SocketEvent(
        type: SocketEventType.countdown,
        data: {'countdown': 9},
      ),
    );

    expect((await first).data['countdown'], 9);
    expect((await second).data['countdown'], 9);
    await socket.dispose();
  });

  test('live socket sends AUTH, PLACE_BET, and PING contract payloads',
      () async {
    final connection = FakeSocketConnection();
    final socket = LiveSocketService(
      url: 'ws://example.test',
      connector: (_) async => connection,
    );
    await socket.connect();

    socket.authenticate('jwt-token');
    socket.placeBet(raceId: 'race_1', horseId: 'horse_2', amount: 2000);
    socket.ping();

    expect(connection.decodedSent, [
      {
        'type': 'AUTH',
        'data': {'token': 'jwt-token'},
      },
      {
        'type': 'PLACE_BET',
        'data': {'raceId': 'race_1', 'horseId': 'horse_2', 'amount': 2000.0},
      },
      {'type': 'PING', 'data': <String, dynamic>{}},
    ]);
    await socket.dispose();
  });

  test('malformed messages emit an error and leave stream active', () async {
    final connection = FakeSocketConnection();
    final socket = LiveSocketService(
      url: 'ws://example.test',
      connector: (_) async => connection,
    );
    await socket.connect();
    final received = <SocketEvent>[];
    final subscription = socket.events.listen(received.add);

    connection.receive('not-json');
    connection.receive(jsonEncode({'type': 'PONG', 'data': {}}));
    await pumpEventQueue();

    expect(received.map((event) => event.type), [
      SocketEventType.error,
      SocketEventType.pong,
    ]);
    expect(received.first.data['message'], contains('Malformed'));
    await subscription.cancel();
    await socket.dispose();
  });

  test('unexpected close reconnects and re-authenticates', () async {
    final first = FakeSocketConnection();
    final second = FakeSocketConnection();
    final connections = [first, second];
    var connectorCalls = 0;
    final socket = LiveSocketService(
      url: 'ws://example.test',
      connector: (_) async => connections[connectorCalls++],
      reconnectDelay: (_) async {},
      maxReconnectAttempts: 2,
    );
    await socket.connect();
    socket.authenticate('jwt-token');

    await first.endFromServer();
    await pumpEventQueue(times: 10);

    expect(connectorCalls, 2);
    expect(socket.isConnected, isTrue);
    expect(second.decodedSent, [
      {
        'type': 'AUTH',
        'data': {'token': 'jwt-token'},
      },
    ]);
    await socket.dispose();
  });

  test('explicit disconnect never reconnects', () async {
    final connection = FakeSocketConnection();
    var connectorCalls = 0;
    final socket = LiveSocketService(
      url: 'ws://example.test',
      connector: (_) async {
        connectorCalls++;
        return connection;
      },
      reconnectDelay: (_) async {},
    );
    await socket.connect();

    await socket.disconnect();
    await pumpEventQueue(times: 10);

    expect(connectorCalls, 1);
    expect(socket.isConnected, isFalse);
    await socket.dispose();
  });
}

class FakeSocketConnection implements SocketConnection {
  final _incoming = StreamController<dynamic>();
  final sent = <dynamic>[];

  @override
  Stream<dynamic> get stream => _incoming.stream;

  List<Map<String, dynamic>> get decodedSent => sent
      .map((value) => jsonDecode(value as String) as Map<String, dynamic>)
      .toList();

  @override
  void add(dynamic data) => sent.add(data);

  void receive(dynamic data) => _incoming.add(data);

  Future<void> endFromServer() => _incoming.close();

  @override
  Future<void> close() async {
    if (!_incoming.isClosed) {
      await _incoming.close();
    }
  }
}
