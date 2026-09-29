import 'package:flutter_horse_racing/core/bootstrap/core_dependencies.dart';
import 'package:flutter_horse_racing/core/config/app_config.dart';
import 'package:flutter_horse_racing/core/network/http_api_client.dart';
import 'package:flutter_horse_racing/core/network/mock_api_client.dart';
import 'package:flutter_horse_racing/core/socket/live_socket_service.dart';
import 'package:flutter_horse_racing/core/socket/mock_socket_service.dart';
import 'package:flutter_horse_racing/core/socket/socket_event.dart';
import 'package:flutter_horse_racing/models/race_state_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('mock composition exposes mock clients and shared socket behavior',
      () async {
    final dependencies = await CoreDependencies.mock();

    expect(dependencies.config.dataSourceMode, DataSourceMode.mock);
    expect(dependencies.apiClient, isA<MockApiClient>());
    expect(dependencies.socketService, isA<MockSocketService>());
    expect(dependencies.walletProvider.cash, 50000);

    final socket = dependencies.socketService as MockSocketService;
    socket.emit(
      const SocketEvent(
        type: SocketEventType.balanceUpdate,
        data: {'cash': 49000},
      ),
    );
    socket.emit(
      const SocketEvent(
        type: SocketEventType.raceCancelled,
        data: {},
      ),
    );
    await pumpEventQueue();

    expect(dependencies.walletProvider.cash, 49000);
    expect(dependencies.gameProvider.phase, RacePhase.cancelled);
    await dependencies.dispose();
  });

  test('live composition exposes live clients configured for DEV 1', () async {
    const config = AppConfig.live(
      baseUrl: 'http://10.0.2.2:3000',
      wsUrl: 'ws://10.0.2.2:3000',
    );

    final dependencies = await CoreDependencies.live(config: config);

    expect(dependencies.config, same(config));
    expect(dependencies.apiClient, isA<HttpApiClient>());
    expect(dependencies.socketService, isA<LiveSocketService>());
    expect((dependencies.apiClient as HttpApiClient).baseUrl, config.baseUrl);
    expect((dependencies.socketService as LiveSocketService).url, config.wsUrl);
    await dependencies.dispose();
  });
}
