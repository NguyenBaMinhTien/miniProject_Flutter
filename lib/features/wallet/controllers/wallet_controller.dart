// DEV 4 Scope: Controller Quản lý trạng thái và logic Ví tiền (Wallet Controller)
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../wallet_mock_data.dart';
import '../wallet_system.dart';

/// Trạng thái hoạt động của màn hình Ví
enum WalletStatus {
  initial, // Trạng thái khởi tạo ban đầu
  loading, // Đang tải dữ liệu hoặc đang nạp tiền
  success, // Tải dữ liệu hoặc nạp tiền thành công
  empty, // Không có giao dịch nào
  error, // Gặp lỗi trong quá trình xử lý
}

/// Controller điều hướng dữ liệu theo mô hình MVC (Provider / ChangeNotifier)
class WalletController extends ChangeNotifier {
  // Số dư khả dụng hiện tại (Mặc định khởi tạo theo WalletSystem)
  double _cash = WalletSystem.initialMockCash;

  // Trạng thái hiện tại của Controller
  WalletStatus _status = WalletStatus.initial;

  // Thông báo lỗi (nếu có)
  String? _errorMessage;

  // Danh sách lịch sử giao dịch
  final List<TransactionModel> _transactions = [];

  // Getter công khai cho UI đọc dữ liệu
  double get cash => _cash;
  WalletStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  WalletController({bool loadMock = true}) {
    // Khởi tạo dữ liệu giả lập từ WalletMockData nếu loadMock = true
    if (loadMock) {
      _loadInitialMockData();
    } else {
      _status = WalletStatus.empty;
    }
  }

  /// Nạp danh sách giao dịch giả lập ban đầu để test giao diện (Mock Data)
  void _loadInitialMockData() {
    _status = WalletStatus.loading;
    notifyListeners(); // Thông báo cho UI hiển thị loading

    // Tách nguồn Mock Data sang WalletMockData
    _transactions.addAll(WalletMockData.defaultTransactions);
    _cash = WalletMockData.initialBalance; // 60,000đ

    _status = WalletStatus.success;
    notifyListeners(); // Cập nhật lại giao diện UI
  }

  /// Hàm giả lập Nạp tiền nhanh (Mock Deposit)
  /// - [amount]: Số tiền người dùng chọn nạp (Ví dụ: 50,000đ)
  Future<bool> mockDeposit(double amount) async {
    if (amount <= 0) {
      _errorMessage = 'Số tiền nạp không hợp lệ';
      _status = WalletStatus.error;
      notifyListeners();
      return false;
    }

    _status = WalletStatus.loading;
    notifyListeners();

    // Giả lập độ trễ mạng theo WalletSystem
    await Future.delayed(WalletSystem.mockNetworkDelay);

    // Cộng số dư ví
    _cash += amount;

    // Khởi tạo bản ghi giao dịch nạp tiền mới từ Mock Data generator
    final newTx = WalletMockData.createDepositTransaction(
      amount: amount,
      newBalance: _cash,
    );

    // Chèn giao dịch mới lên đầu danh sách
    _transactions.insert(0, newTx);

    _status = WalletStatus.success;
    _errorMessage = null;
    notifyListeners(); // Cập nhật số dư và lịch sử lên UI ngay lập tức
    return true;
  }

  /// Cập nhật số dư theo thời gian thực (Realtime Balance Update)
  /// Dùng khi kết nối sự kiện WebSocket từ Game Engine (Đặt cược / Thắng cược / Hoàn tiền)
  void updateBalanceRealtime(double delta, TransactionType type, String description) {
    _cash += delta;
    final newTx = WalletMockData.createRealtimeTransaction(
      delta: delta,
      newBalance: _cash,
      type: type,
      description: description,
    );
    _transactions.insert(0, newTx);
    notifyListeners();
  }

  /// Hàm làm mới danh sách (Pull-to-refresh)
  Future<void> refresh() async {
    _status = WalletStatus.loading;
    notifyListeners();
    await Future.delayed(WalletSystem.mockRefreshDelay);
    _status = WalletStatus.success;
    notifyListeners();
  }
}
