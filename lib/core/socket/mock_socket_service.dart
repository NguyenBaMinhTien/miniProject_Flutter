import 'dart:async';

import 'socket_event.dart';
import 'socket_service.dart';

class MockSocketService implements SocketService {
  final _events = StreamController<SocketEvent>.broadcast();
  bool _connected = false;
  bool _disposed = false;
  int _betSequence = 0;

  @override
  Stream<SocketEvent> get events => _events.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    _ensureActive();
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  @override
  void authenticate(String token) {
    _ensureConnected();
    emit(
      const SocketEvent(
        type: SocketEventType.authSuccess,
        data: {'authenticated': true},
      ),
    );
  }

  @override
  void placeBet({
    required String raceId,
    required String horseId,
    required double amount,
  }) {
    _ensureConnected();
    emit(
      SocketEvent(
        type: SocketEventType.betConfirmed,
        data: {
          'id': 'mock_bet_${++_betSequence}',
          'raceId': raceId,
          'horseId': horseId,
          'horseName': 'Mock Horse',
          'odds': 2.0,
          'amount': amount,
          'potentialPayout': amount * 2,
          'payout': 0.0,
          'status': 'PENDING',
          'placedAt':
              DateTime.utc(2026, 9, 29, 10, 0, _betSequence).toIso8601String(),
        },
      ),
    );
  }

  @override
  void ping() {
    _ensureConnected();
    emit(const SocketEvent(type: SocketEventType.pong, data: {}));
  }

  void emit(SocketEvent event) {
    _ensureActive();
    _events.add(event);
  }

  void seedRace() {
    emit(
      const SocketEvent(
        type: SocketEventType.raceState,
        data: {
          'raceId': 'mock_race_1',
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
          'positions': {'horse_1': 0.0, 'horse_2': 0.0},
          'winnerId': null,
        },
      ),
    );
  }

  void _ensureActive() {
    if (_disposed) throw StateError('SocketService has been disposed');
  }

  void _ensureConnected() {
    _ensureActive();
    if (!_connected) throw StateError('WebSocket is not connected');
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _connected = false;
    await _events.close();
  }
}
