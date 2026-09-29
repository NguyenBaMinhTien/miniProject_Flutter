enum AppEnvironment { development, staging, production }

enum DataSourceMode { mock, live }

class AppConfig {
  const AppConfig({
    required this.baseUrl,
    required this.wsUrl,
    required this.minBet,
    required this.maxBet,
    required this.betAmounts,
    required this.environment,
    required this.dataSourceMode,
  });

  const AppConfig.mock({
    this.baseUrl = 'http://localhost:3000',
    this.wsUrl = 'ws://localhost:3000',
    this.minBet = 100,
    this.maxBet = 10000,
    this.betAmounts = const [100, 200, 500, 1000, 2000, 5000, 10000],
    this.environment = AppEnvironment.development,
  }) : dataSourceMode = DataSourceMode.mock;

  const AppConfig.live({
    required this.baseUrl,
    required this.wsUrl,
    this.minBet = 100,
    this.maxBet = 10000,
    this.betAmounts = const [100, 200, 500, 1000, 2000, 5000, 10000],
    this.environment = AppEnvironment.development,
  }) : dataSourceMode = DataSourceMode.live;

  final String baseUrl;
  final String wsUrl;
  final double minBet;
  final double maxBet;
  final List<double> betAmounts;
  final AppEnvironment environment;
  final DataSourceMode dataSourceMode;
}
