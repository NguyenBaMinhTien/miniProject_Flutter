import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_exception.dart';

typedef TokenProvider = Future<String?> Function();
typedef UnauthorizedCallback = Future<void> Function();

class HttpApiClient implements ApiClient {
  HttpApiClient({
    required String baseUrl,
    http.Client? client,
    this.tokenProvider,
    this.onUnauthorized,
    this.requestTimeout = const Duration(seconds: 15),
  })  : baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  final TokenProvider? tokenProvider;
  final UnauthorizedCallback? onUnauthorized;
  final Duration requestTimeout;

  @override
  Future<Map<String, dynamic>> get(String path) {
    return _send('GET', path);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final request = http.Request(method, _resolve(path));
      request.headers['accept'] = 'application/json';
      request.headers['content-type'] = 'application/json; charset=utf-8';

      final token = await tokenProvider?.call();
      if (token != null && token.isNotEmpty) {
        request.headers['authorization'] = 'Bearer $token';
      }
      if (body != null) {
        request.body = jsonEncode(body);
      }

      final response = await (() async {
        final streamed = await _client.send(request);
        return http.Response.fromStream(streamed);
      })()
          .timeout(requestTimeout);

      if (response.statusCode == 401) {
        final decoded = _tryDecode(response);
        Object? cleanupError;
        try {
          await onUnauthorized?.call();
        } catch (error) {
          cleanupError = error;
        }
        throw ApiException(
          decoded?['message']?.toString() ?? 'Unauthorized',
          statusCode: 401,
          cause: cleanupError,
        );
      }
      final decoded = _decode(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          decoded['message']?.toString() ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
      return decoded;
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Network request failed', cause: error);
    }
  }

  Uri _resolve(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized');
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final value = jsonDecode(response.body);
      if (value is Map<String, dynamic>) {
        return value;
      }
      throw const FormatException('Expected a JSON object');
    } catch (error) {
      throw ApiException(
        'Invalid server response',
        statusCode: response.statusCode,
        cause: error,
      );
    }
  }

  Map<String, dynamic>? _tryDecode(http.Response response) {
    try {
      final value = jsonDecode(response.body);
      return value is Map<String, dynamic> ? value : null;
    } catch (_) {
      return null;
    }
  }

  void close() => _client.close();
}
