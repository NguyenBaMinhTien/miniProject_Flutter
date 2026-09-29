import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';
import '../socket/socket_service.dart';
import '../storage/local_storage.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required ApiClient apiClient,
    required LocalStorage storage,
    required SocketService socketService,
  })  : _apiClient = apiClient,
        _storage = storage,
        _socketService = socketService;

  final ApiClient _apiClient;
  final LocalStorage _storage;
  final SocketService _socketService;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

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
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.post(endpoint, body: body);
      await _handleAuthenticationResponse(response);
      return true;
    } catch (error) {
      await _rollbackAuthentication();
      _error = _messageFor(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleAuthenticationResponse(
    Map<String, dynamic> response,
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

    await _storage.saveToken(token);
    await _storage.saveUsername(parsedUser.username);
    await _socketService.connect();
    _socketService.authenticate(token);
    _user = parsedUser;
    notifyListeners();
  }

  Future<bool> autoLogin() async {
    _setLoading(true);
    _error = null;
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) return false;

      final response = await _apiClient.get(ApiEndpoints.me);
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
      _socketService.authenticate(token);
      _user = parsedUser;
      notifyListeners();
      return true;
    } catch (error) {
      await _rollbackAuthentication();
      _error = _messageFor(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _storage.clearAuth();
      await _socketService.disconnect();
      _user = null;
      _error = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _rollbackAuthentication() async {
    _user = null;
    await _storage.clearAuth();
    await _socketService.disconnect();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _messageFor(Object error) {
    return error is ApiException ? error.message : 'Authentication failed';
  }
}
