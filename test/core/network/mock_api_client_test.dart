import 'package:flutter_horse_racing/core/network/api_endpoints.dart';
import 'package:flutter_horse_racing/core/network/api_exception.dart';
import 'package:flutter_horse_racing/core/network/mock_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mock auth returns contract-shaped token and user', () async {
    final api = MockApiClient();

    final response = await api.post(
      ApiEndpoints.login,
      body: {'username': 'demo', 'password': 'secret'},
    );

    expect(response['token'], 'mock-jwt-demo');
    expect(response['user'], {
      'id': 'user_demo',
      'username': 'demo',
      'fullName': 'Demo Player',
      'cash': 50000.0,
    });
  });

  test('mock wallet deposit updates cash and transaction history', () async {
    final api = MockApiClient(initialCash: 50000);

    final deposit = await api.post(
      ApiEndpoints.depositMock,
      body: {'amount': 20000},
    );
    final history = await api.get(ApiEndpoints.transactions);

    expect(deposit['cash'], 70000.0);
    expect((deposit['transaction'] as Map<String, dynamic>)['type'], 'DEPOSIT');
    expect(history['cash'], 70000.0);
    expect((history['transactions'] as List<dynamic>), hasLength(1));
  });

  test('mock history routes return deterministic lists', () async {
    final api = MockApiClient();

    expect((await api.get(ApiEndpoints.myBets))['bets'], isA<List<dynamic>>());
    expect((await api.get(ApiEndpoints.raceHistory))['races'],
        isA<List<dynamic>>());
    expect(
      (await api.get(ApiEndpoints.recentWinners))['winners'],
      isA<List<dynamic>>(),
    );
  });

  test('unsupported mock route fails explicitly', () async {
    final api = MockApiClient();

    await expectLater(
      api.get('/api/not-implemented'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 404)
            .having((error) => error.message, 'message',
                contains('not-implemented')),
      ),
    );
  });
}
