import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'socket_event.dart';
import 'socket_service.dart';

abstract interface class SocketConnection {
  Stream<dynamic> get stream;
  void add(dynamic data);
  Future<void> close();
}

typedef SocketConnector = Future<SocketConnection> Function(Uri uri);
typedef ReconnectDelay = Future<void> Function(Duration duration);

class LiveSocketService implements SocketService {
  LiveSocketService({
    required this.url,
    SocketConnector? connector,
    ReconnectDelay? reconnectDelay,
    this.maxReconnectAttempts = 5,
  })  : _connector = connector ?? _connectWebSocket,
        _reconnectDelay = reconnectDelay ?? Future<void>.delayed;

  final String url;
  final int maxReconnectAttempts;
  final SocketConnector _connector;
  final ReconnectDelay _reconnectDelay;
  final _events = StreamController<SocketEvent>.broadcast();

  SocketConnection? _connection;
  StreamSubscription<dynamic>? _subscription;
  String? _lastToken;
  bool _connected = false;
  bool _intentionalDisconnect = false;
  bool _disposed = false;
  bool _reconnecting = false;
  int _connectionGeneration = 0;
  Future<void>? _connectOperation;

  @override
  Stream<SocketEvent> get events => _events.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    if (_disposed) {
      throw StateError('SocketService has been disposed');
    }
    if (_connected) return;
    _intentionalDisconnect = false;
    final generation = _connectionGeneration;
    await _connectOnce(generation);
    if (!_connected &&
        !_intentionalDisconnect &&
        !_disposed &&
        generation == _connectionGeneration) {
      await _connectOnce(generation);
    }
  }

  Future<void> _connectOnce(int generation) {
    final existing = _connectOperation;
    if (existing != null) return existing;
    late final Future<void> trackedOperation;
    trackedOperation = _open(generation).whenComplete(() {
      if (identical(_connectOperation, trackedOperation)) {
        _connectOperation = null;
      }
    });
    _connectOperation = trackedOperation;
    return trackedOperation;
  }

  Future<void> _open(int generation) async {
    final connection = await _connector(Uri.parse(url));
    if (_disposed ||
        _intentionalDisconnect ||
        generation != _connectionGeneration) {
      unawaited(connection.close().catchError((_) {}));
      return;
    }
    _connection = connection;
    _connected = true;
    _subscription = connection.stream.listen(
      _onMessage,
      onError: _onStreamError,
      onDone: () => _onStreamDone(connection, generation),
      cancelOnError: false,
    );
    final token = _lastToken;
    if (token != null) {
      _send('AUTH', {'token': token});
    }
  }

  void _onMessage(dynamic message) {
    try {
      _events.add(SocketEvent.fromMessage(message));
    } catch (error) {
      _events.add(SocketEvent.malformed(error));
    }
  }

  void _onStreamError(Object error, StackTrace stackTrace) {
    _events.add(
      SocketEvent(
        type: SocketEventType.error,
        data: {
          'message': 'WebSocket connection error',
          'cause': error.toString()
        },
      ),
    );
  }

  void _onStreamDone(SocketConnection connection, int generation) {
    if (!identical(_connection, connection) ||
        generation != _connectionGeneration) {
      return;
    }
    _connection = null;
    _subscription = null;
    _connected = false;
    if (!_intentionalDisconnect && !_disposed) {
      unawaited(_reconnect());
    }
  }

  Future<void> _reconnect() async {
    if (_reconnecting) return;
    _reconnecting = true;
    final generation = _connectionGeneration;
    try {
      for (var attempt = 0; attempt < maxReconnectAttempts; attempt++) {
        if (_intentionalDisconnect ||
            _disposed ||
            generation != _connectionGeneration) {
          return;
        }
        final multiplier = 1 << attempt.clamp(0, 5);
        await _reconnectDelay(Duration(seconds: multiplier));
        if (_intentionalDisconnect ||
            _disposed ||
            generation != _connectionGeneration) {
          return;
        }
        try {
          await _connectOnce(generation);
          if (_connected) return;
        } catch (error) {
          if (attempt == maxReconnectAttempts - 1) {
            _events.add(
              SocketEvent(
                type: SocketEventType.error,
                data: {
                  'message': 'WebSocket reconnect failed',
                  'cause': error.toString(),
                },
              ),
            );
          }
        }
      }
    } finally {
      _reconnecting = false;
    }
  }

  @override
  void authenticate(String token) {
    _lastToken = token;
    _send('AUTH', {'token': token});
  }

  @override
  void placeBet({
    required String raceId,
    required String horseId,
    required double amount,
  }) {
    _send('PLACE_BET', {
      'raceId': raceId,
      'horseId': horseId,
      'amount': amount,
    });
  }

  @override
  void ping() => _send('PING', const {});

  void _send(String type, Map<String, dynamic> data) {
    final connection = _connection;
    if (!_connected || connection == null) {
      throw StateError('WebSocket is not connected');
    }
    connection.add(jsonEncode({'type': type, 'data': data}));
  }

  @override
  Future<void> disconnect() async {
    _connectionGeneration++;
    _intentionalDisconnect = true;
    _lastToken = null;
    _connected = false;
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
    final connection = _connection;
    _connection = null;
    await connection?.close();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await disconnect();
    await _events.close();
  }

  static Future<SocketConnection> _connectWebSocket(Uri uri) async {
    final channel = WebSocketChannel.connect(uri);
    await channel.ready;
    return _WebSocketConnection(channel);
  }
}

class _WebSocketConnection implements SocketConnection {
  _WebSocketConnection(this._channel);

  final WebSocketChannel _channel;

  @override
  Stream<dynamic> get stream => _channel.stream;

  @override
  void add(dynamic data) => _channel.sink.add(data);

  @override
  Future<void> close() async => _channel.sink.close();
}
