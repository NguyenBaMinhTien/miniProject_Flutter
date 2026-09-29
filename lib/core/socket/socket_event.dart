import 'dart:convert';

enum SocketEventType {
  welcome,
  authSuccess,
  raceState,
  countdown,
  raceTick,
  raceFinished,
  betConfirmed,
  betResult,
  balanceUpdate,
  raceCancelled,
  betRefunded,
  error,
  pong,
}

class SocketEvent {
  const SocketEvent({required this.type, required this.data});

  factory SocketEvent.fromMessage(dynamic message) {
    final dynamic decoded = message is String ? jsonDecode(message) : message;
    if (decoded is! Map) {
      throw const FormatException('WebSocket message must be an object');
    }
    final rawType = decoded['type'];
    final rawData = decoded['data'];
    if (rawType is! String || rawData is! Map) {
      throw const FormatException('WebSocket message requires type and data');
    }

    final data = rawData.map<String, dynamic>(
      (key, value) => MapEntry(key.toString(), value),
    );
    final type = _eventTypes[rawType.toUpperCase()];
    if (type == null) {
      return SocketEvent(
        type: SocketEventType.error,
        data: {
          'message': 'Unknown WebSocket event: $rawType',
          'rawType': rawType,
          'rawData': data,
        },
      );
    }
    return SocketEvent(type: type, data: data);
  }

  factory SocketEvent.malformed(Object error) {
    return SocketEvent(
      type: SocketEventType.error,
      data: {
        'message': 'Malformed WebSocket message',
        'cause': error.toString()
      },
    );
  }

  final SocketEventType type;
  final Map<String, dynamic> data;

  static const _eventTypes = <String, SocketEventType>{
    'WELCOME': SocketEventType.welcome,
    'AUTH_SUCCESS': SocketEventType.authSuccess,
    'RACE_STATE': SocketEventType.raceState,
    'COUNTDOWN': SocketEventType.countdown,
    'RACE_TICK': SocketEventType.raceTick,
    'RACE_FINISHED': SocketEventType.raceFinished,
    'BET_CONFIRMED': SocketEventType.betConfirmed,
    'BET_RESULT': SocketEventType.betResult,
    'BALANCE_UPDATE': SocketEventType.balanceUpdate,
    'RACE_CANCELLED': SocketEventType.raceCancelled,
    'BET_REFUNDED': SocketEventType.betRefunded,
    'ERROR': SocketEventType.error,
    'PONG': SocketEventType.pong,
  };
}
