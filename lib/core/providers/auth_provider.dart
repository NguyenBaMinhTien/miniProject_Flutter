import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';
import '../socket/socket_service.dart';
import '../storage/local_storage.dart';

typedef SessionEndedCallback = FutureOr<void> Function();

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required ApiClient apiClient,
    required LocalStorage storage,
    required SocketService socketService,
    SessionEndedCallback? onSessionEnded,
  })  : _apiClient = apiClient,
        _storage = storage,
        _socketService = socketService,
        _onSessionEnded = onSessionEnded;

  final ApiClient _apiClient;
  final LocalStorage _storage;
  final SocketService _socketService;
  final SessionEndedCallback? _onSessionEnded;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  int _operationId = 0;
  bool _disposed = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login({
    required String username,
    required String password,
  }) {
    return _authenticate(
      ApiEndpoints.login,
      {'username': username, 'password': password},
    );
  }

  Future<bool> register({
    required String fullName,
    required String username,
    required String password,
  }) {
    return _authenticate(
      ApiEndpoints.register,
      {'fullName': fullName, 'username': username, 'password': password},
    );
  }

  Future<bool> _authenticate(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final operation = _beginOperation();
    try {
      final response = await _apiClient.post(endpoint, body: body);
      _requireCurrent(operation);
      await _handleAuthenticationResponse(response, operation);
      _requireCurrent(operation);
      return true;
    } on _StaleAuthenticationOperation {
      await _cleanupSession();
      return false;
    } catch (error) {
      if (!_isCurrent(operation)) return false;
      _user = null;
      await _cleanupSession();
      if (_isCurrent(operation)) {
        _error = _messageFor(error);
        _notify();
      }
      return false;
    } finally {
      if (_isCurrent(operation)) _setLoading(false);
    }
  }

  Future<void> _handleAuthenticationResponse(
    Map<String, dynamic> response,
    int operation,
  ) async {
    final token = response['token'];
    final userJson = response['user'];
    if (token is! String || token.isEmpty || userJson is! Map) {
      throw const ApiException('Invalid authentication response');
    }
    final parsedUser = UserModel.fromJson(
      userJson.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );

    _requireCurrent(operation);
    await _storage.saveToken(token);
    _requireCurrent(operation);
    await _storage.saveUsername(parsedUser.username);
    _requireCurrent(operation);
    await _socketService.connect();
    _requireCurrent(operation);
    _socketService.authenticate(token);
    _requireCurrent(operation);
    _user = parsedUser;
    _notify();
  }

  Future<bool> autoLogin() async {
    final operation = _beginOperation();
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) return false;

      final response = await _apiClient.get(ApiEndpoints.me);
      _requireCurrent(operation);
      final dynamic rawUser = response['user'] ?? response;
      if (rawUser is! Map) {
        throw const ApiException('Invalid user response');
      }
      final parsedUser = UserModel.fromJson(
        rawUser.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
      await _socketService.connect();
      _requireCurrent(operation);
      _socketService.authenticate(token);
      _requireCurrent(operation);
      _user = parsedUser;
      _notify();
      return true;
    } on _StaleAuthenticationOperation {
      await _cleanupSession();
      return false;
    } catch (error) {
      if (!_isCurrent(operation)) return false;
      _user = null;
      await _cleanupSession();
      if (_isCurrent(operation)) {
        _error = _messageFor(error);
        _notify();
      }
      return false;
    } finally {
      if (_isCurrent(operation)) _setLoading(false);
    }
  }

  Future<void> logout() async {
    final operation = ++_operationId;
    if (_disposed) return;
    _setLoading(true);
    _user = null;
    _error = null;
    _notify();
    final cleanupSucceeded = await _cleanupSession();
    if (_isCurrent(operation)) {
      if (!cleanupSucceeded) _error = 'Logout cleanup failed';
      _setLoading(false);
    }
  }

  int _beginOperation() {
    final operation = ++_operationId;
    if (!_disposed) {
      _error = null;
      _setLoading(true);
    }
    return operation;
  }

  bool _isCurrent(int operation) => !_disposed && operation == _operationId;

  void _requireCurrent(int operation) {
    if (!_isCurrent(operation)) throw const _StaleAuthenticationOperation();
  }

  Future<bool> _cleanupSession() async {
    var succeeded = true;
    try {
      await _storage.clearAuth();
    } catch (_) {
      succeeded = false;
    }
    try {
      await _socketService.disconnect();
    } catch (_) {
      succeeded = false;
    }
    try {
      await _onSessionEnded?.call();
    } catch (_) {
      succeeded = false;
    }
    return succeeded;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String _messageFor(Object error) {
    return error is ApiException ? error.message : 'Authentication failed';
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _operationId++;
    _user = null;
    super.dispose();
  }
}

class _StaleAuthenticationOperation implements Exception {
  const _StaleAuthenticationOperation();
}
