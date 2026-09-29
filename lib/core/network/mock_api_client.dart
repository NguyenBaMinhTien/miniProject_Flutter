import 'api_client.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

class MockApiClient implements ApiClient {
  MockApiClient({
    double initialCash = 50000,
    this.latency = Duration.zero,
    DateTime? clock,
  })  : _cash = initialCash,
        _clock = clock ?? DateTime.utc(2026, 9, 29, 10);

  final Duration latency;
  final DateTime _clock;
  double _cash;
  int _transactionSequence = 0;
  final List<Map<String, dynamic>> _transactions = [];

  @override
  Future<Map<String, dynamic>> get(String path) async {
    await _wait();
    switch (path) {
      case ApiEndpoints.me:
        return _authResponse('demo')['user'] as Map<String, dynamic>;
      case ApiEndpoints.transactions:
        return {
          'cash': _cash,
          'transactions': _transactions.map(Map<String, dynamic>.from).toList(),
        };
      case ApiEndpoints.myBets:
        return {'bets': <Map<String, dynamic>>[]};
      case ApiEndpoints.raceHistory:
        return {'races': <Map<String, dynamic>>[]};
      case ApiEndpoints.recentWinners:
        return {'winners': <Map<String, dynamic>>[]};
      default:
        throw ApiException('Mock route not implemented: GET $path',
            statusCode: 404);
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    await _wait();
    switch (path) {
      case ApiEndpoints.login:
        final username = _requiredString(body, 'username');
        _requiredString(body, 'password');
        return _authResponse(username);
      case ApiEndpoints.register:
        final username = _requiredString(body, 'username');
        _requiredString(body, 'password');
        final fullName = _requiredString(body, 'fullName');
        return _authResponse(username, fullName: fullName);
      case ApiEndpoints.depositMock:
        return _deposit(body);
      default:
        throw ApiException('Mock route not implemented: POST $path',
            statusCode: 404);
    }
  }

  Map<String, dynamic> _authResponse(
    String username, {
    String fullName = 'Demo Player',
  }) {
    return {
      'token': 'mock-jwt-$username',
      'user': {
        'id': 'user_$username',
        'username': username,
        'fullName': fullName,
        'cash': _cash,
      },
    };
  }

  Map<String, dynamic> _deposit(Map<String, dynamic>? body) {
    final amountValue = body?['amount'];
    if (amountValue is! num || amountValue <= 0) {
      throw const ApiException('Deposit amount must be positive',
          statusCode: 400);
    }
    final amount = amountValue.toDouble();
    _cash += amount;
    final transaction = <String, dynamic>{
      'id': 'mock_tx_${++_transactionSequence}',
      'type': 'DEPOSIT',
      'amount': amount,
      'balanceAfter': _cash,
      'description': 'Mock deposit',
      'createdAt':
          _clock.add(Duration(seconds: _transactionSequence)).toIso8601String(),
    };
    _transactions.insert(0, transaction);
    return {
      'cash': _cash,
      'transaction': Map<String, dynamic>.from(transaction),
    };
  }

  String _requiredString(Map<String, dynamic>? body, String key) {
    final value = body?[key];
    if (value is! String || value.trim().isEmpty) {
      throw ApiException('$key is required', statusCode: 400);
    }
    return value.trim();
  }

  Future<void> _wait() async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
  }
}
