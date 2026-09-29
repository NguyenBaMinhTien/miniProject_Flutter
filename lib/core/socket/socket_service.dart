import 'socket_event.dart';

abstract interface class SocketService {
  Stream<SocketEvent> get events;
  bool get isConnected;

  Future<void> connect();
  Future<void> disconnect();
  void authenticate(String token);
  void placeBet({
    required String raceId,
    required String horseId,
    required double amount,
  });
  void ping();
  Future<void> dispose();
}
