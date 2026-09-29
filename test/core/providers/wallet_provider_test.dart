import 'package:flutter_horse_racing/core/network/api_client.dart';
import 'package:flutter_horse_racing/core/network/api_exception.dart';
import 'package:flutter_horse_racing/core/network/mock_api_client.dart';
import 'package:flutter_horse_racing/core/providers/wallet_provider.dart';
import 'package:flutter_horse_racing/core/socket/mock_socket_service.dart';
import 'package:flutter_horse_racing/core/socket/socket_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loadTransactions supports empty success state', () async {
    final socket = MockSocketService();
    final provider = WalletProvider(
      apiClient: MockApiClient(initialCash: 50000),
      socketService: socket,
    );

    final succeeded = await provider.loadTransactions();

    expect(succeeded, isTrue);
    expect(provider.cash, 50000);
    expect(provider.transactions, isEmpty);
    expect(provider.isLoading, isFalse);
    expect(provider.error, isNull);
    provider.dispose();
    await socket.dispose();
  });

  test('mockDeposit updates cash and prepends transaction', () async {
    final socket = MockSocketService();
    final provider = WalletProvider(
      apiClient: MockApiClient(initialCash: 50000),
      socketService: socket,
    );

    final succeeded = await provider.mockDeposit(20000);

    expect(succeeded, isTrue);
    expect(provider.cash, 70000);
    expect(provider.transactions, hasLength(1));
    expect(provider.transactions.first.amount, 20000);
    expect(provider.transactions.first.balanceAfter, 70000);
    provider.dispose();
    await socket.dispose();
  });

  test('mockDeposit rejects non-positive values without changing state',
      () async {
    final socket = MockSocketService();
    final provider = WalletProvider(
      apiClient: MockApiClient(initialCash: 50000),
      socketService: socket,
      initialCash: 50000,
    );

    final succeeded = await provider.mockDeposit(0);

    expect(succeeded, isFalse);
    expect(provider.cash, 50000);
    expect(provider.transactions, isEmpty);
    expect(provider.error, 'Deposit amount must be positive');
    expect(provider.isLoading, isFalse);
    provider.dispose();
    await socket.dispose();
  });

  test('balance update event updates cash in realtime', () async {
    final socket = MockSocketService();
    final provider = WalletProvider(
      apiClient: MockApiClient(),
      socketService: socket,
    );

    socket.emit(
      const SocketEvent(
        type: SocketEventType.balanceUpdate,
        data: {'cash': 48000},
      ),
    );
    await pumpEventQueue();

    expect(provider.cash, 48000);
    provider.dispose();
    await socket.dispose();
  });

  test('API failure exposes error and always resets loading', () async {
    final socket = MockSocketService();
    final provider = WalletProvider(
      apiClient: const FailingWalletApiClient(),
      socketService: socket,
    );

    final succeeded = await provider.loadTransactions();

    expect(succeeded, isFalse);
    expect(provider.error, 'Wallet unavailable');
    expect(provider.isLoading, isFalse);
    provider.dispose();
    await socket.dispose();
  });
}

class FailingWalletApiClient implements ApiClient {
  const FailingWalletApiClient();

  @override
  Future<Map<String, dynamic>> get(String path) {
    throw const ApiException('Wallet unavailable', statusCode: 503);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) {
    throw const ApiException('Wallet unavailable', statusCode: 503);
  }
}
