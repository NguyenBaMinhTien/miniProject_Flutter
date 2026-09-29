// DEV 4 Scope: Unit Test và Widget Test cho tính năng Ví Tiền & Nạp Mô Phỏng
// Bao phủ đầy đủ các trường hợp theo mục 16 của phan_cong_5_dev_flutter_horse_racing.md:
// - Empty transaction
// - Mock deposit
// - Balance update
// - Transaction refresh
// - API error
// - System tokens & formatting

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_horse_racing/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_horse_racing/features/wallet/models/transaction_model.dart';
import 'package:flutter_horse_racing/features/wallet/screens/wallet_screen.dart';
import 'package:flutter_horse_racing/features/wallet/wallet_mock_data.dart';
import 'package:flutter_horse_racing/features/wallet/wallet_system.dart';

void main() {
  group('Kiểm thử logic WalletController & WalletSystem (Unit Tests - Mô hình MVC)', () {
    test('1. Trạng thái khởi tạo chứa số dư giả lập và 3 giao dịch mẫu từ WalletMockData', () {
      final controller = WalletController();
      expect(controller.cash, equals(WalletMockData.initialBalance));
      expect(controller.transactions.length, equals(3));
      expect(controller.status, equals(WalletStatus.success));
    });

    test('2. Case: Empty transaction - Khởi tạo trạng thái danh sách giao dịch rỗng', () {
      final controller = WalletController(loadMock: false);
      expect(controller.transactions, isEmpty);
      expect(controller.status, equals(WalletStatus.empty));
    });

    test('3. Case: Mock deposit - Nạp tiền hợp lệ làm tăng số dư ví và lưu giao dịch mới', () async {
      final controller = WalletController();
      final initialBalance = controller.cash;
      const depositAmount = 50000.0;

      final success = await controller.mockDeposit(depositAmount);

      expect(success, isTrue);
      expect(controller.cash, equals(initialBalance + depositAmount));
      expect(controller.transactions.first.type, equals(TransactionType.deposit));
      expect(controller.transactions.first.cashDelta, equals(depositAmount));
    });

    test('4. Case: API / Validation error - Nạp số tiền <= 0 báo lỗi và cập nhật error state', () async {
      final controller = WalletController();
      final initialBalance = controller.cash;

      final success = await controller.mockDeposit(-5000.0);

      expect(success, isFalse);
      expect(controller.cash, equals(initialBalance));
      expect(controller.status, equals(WalletStatus.error));
      expect(controller.errorMessage, isNotNull);
    });

    test('5. Case: Balance update - Cập nhật số dư realtime khi đặt cược hoặc thắng cược', () {
      final controller = WalletController();
      final initialBalance = controller.cash;

      // Giả lập sự kiện trừ tiền cược từ WebSocket
      controller.updateBalanceRealtime(
        -10000.0,
        TransactionType.bet,
        'Đặt cược realtime #1 Xích Thố',
      );

      expect(controller.cash, equals(initialBalance - 10000.0));
      expect(controller.transactions.first.type, equals(TransactionType.bet));

      // Giả lập sự kiện cộng tiền thắng cược từ WebSocket
      controller.updateBalanceRealtime(
        22000.0,
        TransactionType.win,
        'Thắng cược realtime #1 Xích Thố (2.2x)',
      );

      expect(controller.cash, equals(initialBalance - 10000.0 + 22000.0));
      expect(controller.transactions.first.type, equals(TransactionType.win));
    });

    test('6. Case: Transaction refresh - Gọi làm mới dữ liệu (Pull-to-refresh)', () async {
      final controller = WalletController();
      expect(controller.status, equals(WalletStatus.success));

      final refreshFuture = controller.refresh();
      expect(controller.status, equals(WalletStatus.loading));

      await refreshFuture;
      expect(controller.status, equals(WalletStatus.success));
    });

    test('7. WalletSystem Tokens - Kiểm tra các tiện ích định dạng tiền tệ', () {
      expect(WalletSystem.formatCurrency(50000), equals('50,000 đ'));
      expect(WalletSystem.formatDelta(20000), equals('+20,000 đ'));
      expect(WalletSystem.formatDelta(-10000), equals('-10,000 đ'));
      expect(WalletSystem.formatCompact(50000), equals('50k đ'));
      expect(WalletSystem.formatCompact(500), equals('500 đ'));
    });
  });

  group('Kiểm thử giao diện WalletScreen (Widget Tests)', () {
    testWidgets('8. Hiển thị thẻ số dư khả dụng và danh sách lịch sử giao dịch ban đầu', (WidgetTester tester) async {
      final controller = WalletController();

      await tester.pumpWidget(
        MaterialApp(
          home: WalletScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ví Tiền & Nạp Mô Phỏng'), findsOneWidget);
      expect(find.text('Số dư khả dụng'), findsOneWidget);
      expect(find.text('NẠP TIỀN MÔ PHỎNG'), findsOneWidget);
      expect(find.text('Lịch sử giao dịch'), findsOneWidget);
      expect(find.text('Nạp tiền tài khoản mới (Mock)'), findsOneWidget);
    });

    testWidgets('9. Case: Empty transaction UI - Hiển thị thông báo khi chưa có giao dịch', (WidgetTester tester) async {
      final controller = WalletController(loadMock: false);

      await tester.pumpWidget(
        MaterialApp(
          home: WalletScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chưa có giao dịch nào'), findsOneWidget);
    });

    testWidgets('10. Mở Modal DepositBottomSheet và tương tác chọn mốc nạp nhanh', (WidgetTester tester) async {
      final controller = WalletController();

      await tester.pumpWidget(
        MaterialApp(
          home: WalletScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('NẠP TIỀN MÔ PHỎNG'));
      await tester.pumpAndSettle();

      expect(find.text('Nạp nhanh'), findsOneWidget);
      expect(find.text('QR Mô Phỏng'), findsOneWidget);
      expect(find.text('NẠP NGAY'), findsOneWidget);

      // Thử bấm NẠP NGAY mốc mặc định 50,000 đ
      await tester.tap(find.text('NẠP NGAY'));
      await tester.pump(); // Bắt đầu loading
      await tester.pump(const Duration(milliseconds: 350)); // Chờ Future.delayed
      await tester.pumpAndSettle();

      // Kiểm tra số dư tăng thêm 50,000 đ
      expect(controller.cash, equals(110000.0));
    });

    testWidgets('11. Chuyển tab sang VietQR Mock UI và mô phỏng quét QR thành công', (WidgetTester tester) async {
      final controller = WalletController();

      await tester.pumpWidget(
        MaterialApp(
          home: WalletScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('NẠP TIỀN MÔ PHỎNG'));
      await tester.pumpAndSettle();

      // Chuyển sang Tab QR Mô Phỏng
      await tester.tap(find.text('QR Mô Phỏng'));
      await tester.pumpAndSettle();

      expect(find.text('Quét mã QR Mô Phỏng VietQR'), findsOneWidget);
      expect(find.text('Mô phỏng quét QR thành công'), findsOneWidget);

      // Nhấn nút mô phỏng quét QR thành công
      await tester.tap(find.text('Mô phỏng quét QR thành công'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Số dư tăng thêm 50,000 đ từ VietQR mock
      expect(controller.cash, equals(110000.0));
    });

    testWidgets('12. Case: Error state UI - Hiển thị thông báo lỗi và nút Thử lại khi gặp sự cố', (WidgetTester tester) async {
      final controller = WalletController();
      // Kích hoạt trạng thái lỗi
      await controller.mockDeposit(-1);

      await tester.pumpWidget(
        MaterialApp(
          home: WalletScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Số tiền nạp không hợp lệ'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);

      // Bấm nút thử lại
      await tester.tap(find.text('Thử lại'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      expect(controller.status, equals(WalletStatus.success));
    });
  });
}
