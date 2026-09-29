import 'package:flutter_horse_racing/core/network/api_client.dart';
import 'package:flutter_horse_racing/core/network/api_exception.dart';
import 'package:flutter_horse_racing/core/network/mock_api_client.dart';
import 'package:flutter_horse_racing/core/providers/auth_provider.dart';
import 'package:flutter_horse_racing/core/socket/mock_socket_service.dart';
import 'package:flutter_horse_racing/core/socket/socket_event.dart';
import 'package:flutter_horse_racing/core/storage/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<LocalStorage> freshStorage(
      [Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    return LocalStorage(await SharedPreferences.getInstance());
  }

  test('login persists identity and authenticates socket', () async {
    final storage = await freshStorage();
    final socket = MockSocketService();
    final provider = AuthProvider(
      apiClient: MockApiClient(),
      storage: storage,
      socketService: socket,
    );
    final authEvent = socket.events.firstWhere(
      (event) => event.type == SocketEventType.authSuccess,
    );

    final succeeded = await provider.login(
      username: 'demo',
      password: 'secret',
    );

    expect(succeeded, isTrue);
    expect(provider.isAuthenticated, isTrue);
    expect(provider.user?.username, 'demo');
    expect(provider.user?.cash, 50000);
    expect(storage.getToken(), 'mock-jwt-demo');
    expect(storage.getUsername(), 'demo');
    expect(socket.isConnected, isTrue);
    expect((await authEvent).type, SocketEventType.authSuccess);
    provider.dispose();
    await socket.dispose();
  });

  test('register uses full name and persists authentication', () async {
    final storage = await freshStorage();
    final socket = MockSocketService();
    final provider = AuthProvider(
      apiClient: MockApiClient(),
      storage: storage,
      socketService: socket,
    );

    final succeeded = await provider.register(
      fullName: 'New Player',
      username: 'newbie',
      password: 'secret',
    );

    expect(succeeded, isTrue);
    expect(provider.user?.fullName, 'New Player');
    expect(storage.getToken(), 'mock-jwt-newbie');
    provider.dispose();
    await socket.dispose();
  });

  test('failed login exposes error and always clears loading', () async {
    final storage = await freshStorage();
    final socket = MockSocketService();
    final provider = AuthProvider(
      apiClient: const FailingApiClient('Invalid credentials'),
      storage: storage,
      socketService: socket,
    );

    final succeeded = await provider.login(
      username: 'demo',
      password: 'wrong',
    );

    expect(succeeded, isFalse);
    expect(provider.isLoading, isFalse);
    expect(provider.isAuthenticated, isFalse);
    expect(provider.error, 'Invalid credentials');
    expect(storage.getToken(), isNull);
    provider.dispose();
    await socket.dispose();
  });

  test('autoLogin without a token remains logged out', () async {
    final storage = await freshStorage();
    final socket = MockSocketService();
    final provider = AuthProvider(
      apiClient: MockApiClient(),
      storage: storage,
      socketService: socket,
    );

    final succeeded = await provider.autoLogin();

    expect(succeeded, isFalse);
    expect(provider.isLoading, isFalse);
    expect(provider.isAuthenticated, isFalse);
    expect(socket.isConnected, isFalse);
    provider.dispose();
    await socket.dispose();
  });

  test('autoLogin restores user and authenticates socket from token', () async {
    final storage = await freshStorage();
    await storage.saveToken('stored-jwt');
    await storage.saveUsername('demo');
    final socket = MockSocketService();
    final provider = AuthProvider(
      apiClient: MockApiClient(),
      storage: storage,
      socketService: socket,
    );

    final succeeded = await provider.autoLogin();

    expect(succeeded, isTrue);
    expect(provider.user?.username, 'demo');
    expect(socket.isConnected, isTrue);
    provider.dispose();
    await socket.dispose();
  });

  test('logout clears auth storage and disconnects socket', () async {
    final storage = await freshStorage();
    final socket = MockSocketService();
    final provider = AuthProvider(
      apiClient: MockApiClient(),
      storage: storage,
      socketService: socket,
    );
    await provider.login(username: 'demo', password: 'secret');

    await provider.logout();

    expect(provider.user, isNull);
    expect(provider.isAuthenticated, isFalse);
    expect(provider.error, isNull);
    expect(storage.getToken(), isNull);
    expect(storage.getUsername(), isNull);
    expect(socket.isConnected, isFalse);
    provider.dispose();
    await socket.dispose();
  });
}

class FailingApiClient implements ApiClient {
  const FailingApiClient(this.message);

  final String message;

  @override
  Future<Map<String, dynamic>> get(String path) {
    throw ApiException(message, statusCode: 401);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) {
    throw ApiException(message, statusCode: 401);
  }
}
