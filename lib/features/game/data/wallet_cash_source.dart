// DEV 3 Scope: Số dư mà GameScreen đọc, lấy từ WalletProvider (MBE-09) của DEV 1
import 'package:flutter/foundation.dart';

/// Phần GameScreen cần từ `WalletProvider`: đọc `cash` và nghe thay đổi.
///
/// TODO(DEV 3): Khi DEV 1 xong `lib/core/providers/wallet_provider.dart`,
/// thêm adapter bọc WalletProvider rồi truyền vào GameScreen thay MockWalletProvider:
///
///   class WalletProviderCashSource implements WalletCashSource {
///     WalletProviderCashSource(this.provider);
///     final WalletProvider provider;
///     @override int get cash => provider.cash.toInt();
///     @override void addListener(VoidCallback l) => provider.addListener(l);
///     @override void removeListener(VoidCallback l) => provider.removeListener(l);
///   }
abstract class WalletCashSource implements Listenable {
  int get cash;
}

/// Giả lập WalletProvider cho tới khi DEV 1 xong.
/// Chỉ server (ở đây là MockGameController) đổi số dư, qua BALANCE_UPDATE.
class MockWalletProvider extends ChangeNotifier implements WalletCashSource {
  MockWalletProvider({int initialCash = 50000}) : _cash = initialCash;

  int _cash;

  @override
  int get cash => _cash;

  /// Tương ứng event BALANCE_UPDATE: server gửi số dư mới.
  void applyBalanceUpdate(int cash) {
    if (cash == _cash) return;
    _cash = cash;
    notifyListeners();
  }
}
