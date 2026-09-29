import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../models/transaction_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';
import '../socket/socket_event.dart';
import '../socket/socket_service.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider({
    required ApiClient apiClient,
    required SocketService socketService,
    double initialCash = 0,
  })  : _apiClient = apiClient,
        _socketService = socketService,
        _cash = initialCash {
    _subscription = _socketService.events.listen(_handleSocketEvent);
  }

  final ApiClient _apiClient;
  final SocketService _socketService;
  late final StreamSubscription<SocketEvent> _subscription;

  double _cash;
  final List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  double get cash => _cash;
  List<TransactionModel> get transactions =>
      UnmodifiableListView(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> loadTransactions() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.get(ApiEndpoints.transactions);
      final cashValue = response['cash'];
      final transactionValues = response['transactions'];
      if (cashValue is! num || transactionValues is! List) {
        throw const ApiException('Invalid wallet response');
      }
      final parsedTransactions = transactionValues.map((value) {
        if (value is! Map) {
          throw const ApiException('Invalid transaction response');
        }
        return TransactionModel.fromJson(
          value.map<String, dynamic>(
            (key, item) => MapEntry(key.toString(), item),
          ),
        );
      }).toList(growable: false);

      _cash = cashValue.toDouble();
      _transactions
        ..clear()
        ..addAll(parsedTransactions);
      return true;
    } catch (error) {
      _error = _messageFor(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> mockDeposit(double amount) async {
    if (amount <= 0) {
      _error = 'Deposit amount must be positive';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.post(
        ApiEndpoints.depositMock,
        body: {'amount': amount},
      );
      final cashValue = response['cash'];
      final transactionValue = response['transaction'];
      if (cashValue is! num || transactionValue is! Map) {
        throw const ApiException('Invalid deposit response');
      }
      final transaction = TransactionModel.fromJson(
        transactionValue.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
      _cash = cashValue.toDouble();
      _upsertTransaction(transaction, prepend: true);
      return true;
    } catch (error) {
      _error = _messageFor(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _handleSocketEvent(SocketEvent event) {
    if (event.type != SocketEventType.balanceUpdate &&
        event.type != SocketEventType.betRefunded) {
      return;
    }
    try {
      final cashValue = event.data['cash'];
      if (cashValue != null) {
        if (cashValue is! num) {
          throw const FormatException('cash must be numeric');
        }
        _cash = cashValue.toDouble();
      }
      final transactionValue = event.data['transaction'];
      if (transactionValue is Map) {
        _upsertTransaction(
          TransactionModel.fromJson(
            transactionValue.map<String, dynamic>(
              (key, value) => MapEntry(key.toString(), value),
            ),
          ),
          prepend: true,
        );
      }
      notifyListeners();
    } catch (error) {
      _error = 'Invalid wallet event: $error';
      notifyListeners();
    }
  }

  void _upsertTransaction(
    TransactionModel transaction, {
    required bool prepend,
  }) {
    final index = _transactions.indexWhere((item) => item.id == transaction.id);
    if (index != -1) _transactions.removeAt(index);
    if (prepend) {
      _transactions.insert(0, transaction);
    } else {
      _transactions.add(transaction);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _messageFor(Object error) {
    return error is ApiException ? error.message : 'Wallet request failed';
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
