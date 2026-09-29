abstract final class ApiEndpoints {
  static const register = '/api/auth/register';
  static const login = '/api/auth/login';
  static const me = '/api/auth/me';

  static const transactions = '/api/wallet/transactions';
  static const depositMock = '/api/wallet/deposit-mock';

  static const myBets = '/api/game/my-bets';
  static const raceHistory = '/api/game/history';
  static const recentWinners = '/api/game/recent-winners';
}
