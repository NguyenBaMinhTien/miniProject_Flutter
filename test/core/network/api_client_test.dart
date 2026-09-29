import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_horse_racing/core/config/app_config.dart';
import 'package:flutter_horse_racing/core/network/api_endpoints.dart';
import 'package:flutter_horse_racing/core/network/api_exception.dart';
import 'package:flutter_horse_racing/core/network/http_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('configuration exposes stable endpoints and betting values', () {
    const config = AppConfig.mock();

    expect(config.baseUrl, 'http://localhost:3000');
    expect(config.wsUrl, 'ws://localhost:3000');
    expect(config.dataSourceMode, DataSourceMode.mock);
    expect(config.minBet, 100);
    expect(config.maxBet, 10000);
    expect(config.betAmounts, [100, 200, 500, 1000, 2000, 5000, 10000]);
    expect(ApiEndpoints.login, '/api/auth/login');
    expect(ApiEndpoints.depositMock, '/api/wallet/deposit-mock');
    expect(ApiEndpoints.myBets, '/api/game/my-bets');
  });

  test('GET joins URL, decodes JSON, and attaches bearer token', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(jsonEncode({'status': 'ok'}), 200);
    });
    final api = HttpApiClient(
      baseUrl: 'https://api.example.test/',
      client: client,
      tokenProvider: () async => 'jwt-token',
    );

    final response = await api.get('/api/health');

    expect(captured.url.toString(), 'https://api.example.test/api/health');
    expect(captured.headers['authorization'], 'Bearer jwt-token');
    expect(response, {'status': 'ok'});
  });

  test('POST encodes JSON body and content type', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(jsonEncode({'accepted': true}), 201);
    });
    final api = HttpApiClient(
      baseUrl: 'https://api.example.test',
      client: client,
    );

    final response = await api.post(
      '/api/items',
      body: {'amount': 2000},
    );

    expect(captured.headers['content-type'], contains('application/json'));
    expect(jsonDecode(captured.body), {'amount': 2000});
    expect(response, {'accepted': true});
  });

  test('non-JSON success maps to a stable API exception', () async {
    final api = HttpApiClient(
      baseUrl: 'https://api.example.test',
      client: MockClient((_) async => http.Response('not-json', 200)),
    );

    await expectLater(
      api.get('/api/broken'),
      throwsA(
        isA<ApiException>()
            .having(
                (error) => error.message, 'message', 'Invalid server response')
            .having((error) => error.statusCode, 'statusCode', 200),
      ),
    );
  });

  test('HTTP errors expose backend message', () async {
    final api = HttpApiClient(
      baseUrl: 'https://api.example.test',
      client: MockClient(
        (_) async =>
            http.Response(jsonEncode({'message': 'Bet is closed'}), 409),
      ),
    );

    await expectLater(
      api.post('/api/bet'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.message, 'message', 'Bet is closed')
            .having((error) => error.statusCode, 'statusCode', 409),
      ),
    );
  });

  test('401 invokes unauthorized callback before throwing', () async {
    var unauthorizedCalls = 0;
    final api = HttpApiClient(
      baseUrl: 'https://api.example.test',
      client: MockClient(
        (_) async =>
            http.Response(jsonEncode({'message': 'Token expired'}), 401),
      ),
      onUnauthorized: () async => unauthorizedCalls++,
    );

    await expectLater(api.get('/api/me'), throwsA(isA<ApiException>()));

    expect(unauthorizedCalls, 1);
  });

  test('malformed 401 still invokes callback and preserves status', () async {
    var unauthorizedCalls = 0;
    final api = HttpApiClient(
      baseUrl: 'https://api.example.test',
      client: MockClient((_) async => http.Response('', 401)),
      onUnauthorized: () async => unauthorizedCalls++,
    );

    await expectLater(
      api.get('/api/me'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 401),
      ),
    );
    expect(unauthorizedCalls, 1);
  });

  test('failing unauthorized cleanup does not replace HTTP 401', () async {
    final api = HttpApiClient(
      baseUrl: 'https://api.example.test',
      client: MockClient(
        (_) async => http.Response(jsonEncode({'message': 'Expired'}), 401),
      ),
      onUnauthorized: () async => throw StateError('cleanup failed'),
    );

    await expectLater(
      api.get('/api/me'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.message, 'message', 'Expired')
            .having((error) => error.statusCode, 'statusCode', 401),
      ),
    );
  });

  test('transport failures map to a stable API exception', () async {
    final api = HttpApiClient(
      baseUrl: 'https://api.example.test',
      client: MockClient((_) async => throw const SocketException('offline')),
    );

    await expectLater(
      api.get('/api/health'),
      throwsA(
        isA<ApiException>()
            .having(
                (error) => error.message, 'message', 'Network request failed')
            .having((error) => error.cause, 'cause', isA<SocketException>()),
      ),
    );
  });

  test('request timeout includes response body consumption', () async {
    final client = HangingBodyClient();
    final api = HttpApiClient(
      baseUrl: 'https://api.example.test',
      client: client,
      requestTimeout: const Duration(milliseconds: 20),
    );

    try {
      await expectLater(
        api.get('/api/hanging').timeout(
              const Duration(milliseconds: 200),
              onTimeout: () => throw StateError('body timeout was not applied'),
            ),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.message,
                'message',
                'Network request failed',
              )
              .having((error) => error.cause, 'cause', isA<TimeoutException>()),
        ),
      );
    } finally {
      api.close();
    }
  });
}

class HangingBodyClient extends http.BaseClient {
  final _body = StreamController<List<int>>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(_body.stream, 200);
  }

  @override
  void close() {
    _body.close();
  }
}
