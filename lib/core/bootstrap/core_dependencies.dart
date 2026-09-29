import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/http_api_client.dart';
import '../network/mock_api_client.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../providers/wallet_provider.dart';
import '../socket/live_socket_service.dart';
import '../socket/mock_socket_service.dart';
import '../socket/socket_service.dart';
import '../storage/local_storage.dart';

class CoreDependencies {
  CoreDependencies._({
    required this.config,
    required this.apiClient,
    required this.storage,
    required this.socketService,
    required this.authProvider,
    required this.gameProvider,
    required this.walletProvider,
  });

  final AppConfig config;
  final ApiClient apiClient;
  final LocalStorage storage;
  final SocketService socketService;
  final AuthProvider authProvider;
  final GameProvider gameProvider;
  final WalletProvider walletProvider;

  static Future<CoreDependencies> mock({
    AppConfig config = const AppConfig.mock(),
    LocalStorage? storage,
    double initialCash = 50000,
  }) async {
    final resolvedStorage = storage ?? await LocalStorage.create();
    final socketService = MockSocketService();
    final apiClient = MockApiClient(initialCash: initialCash);
    return _compose(
      config: config,
      apiClient: apiClient,
      storage: resolvedStorage,
      socketService: socketService,
      initialCash: initialCash,
    );
  }

  static Future<CoreDependencies> live({
    required AppConfig config,
    LocalStorage? storage,
    SocketConnector? socketConnector,
  }) async {
    if (config.dataSourceMode != DataSourceMode.live) {
      throw ArgumentError.value(
        config.dataSourceMode,
        'config.dataSourceMode',
        'Live dependencies require DataSourceMode.live',
      );
    }
    final resolvedStorage = storage ?? await LocalStorage.create();
    final socketService = LiveSocketService(
      url: config.wsUrl,
      connector: socketConnector,
    );
    late AuthProvider authProvider;
    final apiClient = HttpApiClient(
      baseUrl: config.baseUrl,
      tokenProvider: () async => resolvedStorage.getToken(),
      onUnauthorized: () async => authProvider.logout(),
    );
    final dependencies = _compose(
      config: config,
      apiClient: apiClient,
      storage: resolvedStorage,
      socketService: socketService,
      initialCash: 0,
    );
    authProvider = dependencies.authProvider;
    return dependencies;
  }

  static CoreDependencies _compose({
    required AppConfig config,
    required ApiClient apiClient,
    required LocalStorage storage,
    required SocketService socketService,
    required double initialCash,
  }) {
    final authProvider = AuthProvider(
      apiClient: apiClient,
      storage: storage,
      socketService: socketService,
    );
    final gameProvider = GameProvider(socketService: socketService);
    final walletProvider = WalletProvider(
      apiClient: apiClient,
      socketService: socketService,
      initialCash: initialCash,
    );
    return CoreDependencies._(
      config: config,
      apiClient: apiClient,
      storage: storage,
      socketService: socketService,
      authProvider: authProvider,
      gameProvider: gameProvider,
      walletProvider: walletProvider,
    );
  }

  Future<void> dispose() async {
    authProvider.dispose();
    gameProvider.dispose();
    walletProvider.dispose();
    await socketService.dispose();
    if (apiClient is HttpApiClient) {
      (apiClient as HttpApiClient).close();
    }
  }
}
