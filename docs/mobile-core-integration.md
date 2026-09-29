# Mobile Core Integration

DEV 6 owns the mobile integration layer in `lib/core/**` and the shared models
in `lib/models/**`. Feature screens consume `AuthProvider`, `GameProvider`, and
`WalletProvider`; screens do not call REST or WebSocket packages directly.

## Start With Mock Data

Initialize Flutter before creating dependencies because local storage uses a
platform plugin:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final core = await CoreDependencies.mock();

  // Pass these existing ChangeNotifiers to the app's state-management shell:
  // core.authProvider
  // core.gameProvider
  // core.walletProvider
  runApp(const HorseRacingApp());
}
```

Mock mode starts the wallet at `50000`, supports login/register, returns empty
history lists, accepts demo deposits, and exposes a deterministic socket. A
development harness can seed a race explicitly:

```dart
final socket = core.socketService as MockSocketService;
await socket.connect();
socket.seedRace();
```

The mock credentials are intentionally permissive: any non-empty username and
password are accepted. This is development data only.

## Provider Responsibilities

### AuthProvider

```dart
await core.authProvider.login(username: 'demo', password: 'secret');
await core.authProvider.register(
  fullName: 'Demo Player',
  username: 'demo',
  password: 'secret',
);
await core.authProvider.autoLogin();
await core.authProvider.logout();
```

The provider persists the JWT and username, connects the socket, and sends
`AUTH`. UI reads `user`, `isAuthenticated`, `isLoading`, and `error`.

### GameProvider

```dart
core.gameProvider.placeBet(
  raceId: core.gameProvider.raceState!.raceId,
  horseId: 'horse_2',
  amount: 2000,
);
```

UI reads `raceState`, `phase`, `countdown`, `positions`,
`myBetsThisRound`, `lastBetResult`, and `error`. Betting is always sent over
WebSocket, never REST.

### WalletProvider

```dart
await core.walletProvider.loadTransactions();
await core.walletProvider.mockDeposit(50000);
```

UI reads `cash`, `transactions`, `isLoading`, and `error`. `BALANCE_UPDATE`
events update cash without requiring a REST refresh.

## Connect to DEV 1

Replace the mock composition call with live composition:

```dart
const config = AppConfig.live(
  baseUrl: 'http://10.0.2.2:3000',
  wsUrl: 'ws://10.0.2.2:3000',
);

final core = await CoreDependencies.live(config: config);
```

Host selection during local development:

- Android emulator: `10.0.2.2` reaches the development machine.
- iOS simulator: `localhost` normally reaches the development machine.
- Physical device: use the development machine's reachable LAN address.
- Production: use HTTPS and WSS URLs supplied by deployment configuration.

The UI and provider calls remain unchanged. If DEV 1's payload fields differ,
update only the relevant `fromJson` method or infrastructure adapter.

## Required REST Contract

Every successful response is a JSON object. Errors should use a non-2xx status
and provide `{ "message": "..." }`. Protected endpoints accept
`Authorization: Bearer <jwt>`.

| Method | Endpoint | Required response fields |
|---|---|---|
| POST | `/api/auth/register` | `token`, `user` |
| POST | `/api/auth/login` | `token`, `user` |
| GET | `/api/auth/me` | user fields directly or under `user` |
| GET | `/api/wallet/transactions` | `cash`, `transactions` |
| POST | `/api/wallet/deposit-mock` | `cash`, `transaction` |
| GET | `/api/game/my-bets` | `bets` |
| GET | `/api/game/history` | `races` |
| GET | `/api/game/recent-winners` | `winners` |

Authentication response example:

```json
{
  "token": "jwt-value",
  "user": {
    "id": "user_1",
    "username": "demo",
    "fullName": "Demo Player",
    "cash": 50000
  }
}
```

## Required WebSocket Contract

All messages use this envelope:

```json
{
  "type": "EVENT_NAME",
  "data": {}
}
```

Client to server:

- `AUTH`: `data.token`
- `PLACE_BET`: `data.raceId`, `data.horseId`, `data.amount`
- `PING`: empty `data`

Server to client:

- `WELCOME`
- `AUTH_SUCCESS`
- `RACE_STATE`
- `COUNTDOWN`
- `RACE_TICK`
- `RACE_FINISHED`
- `BET_CONFIRMED`
- `BET_RESULT`
- `BALANCE_UPDATE`
- `RACE_CANCELLED`
- `BET_REFUNDED`
- `ERROR`
- `PONG`

`RACE_STATE` must match `RaceStateModel`. Bet events must match `BetModel` or
place the same object under `data.bet`. `BALANCE_UPDATE` should provide
`data.cash`; it may also provide a `TransactionModel` under `data.transaction`.

## Mock-to-Live Checklist

1. Confirm DEV 1 implements every REST endpoint and WebSocket event above.
2. Set the environment-specific REST and WebSocket URLs.
3. Change `CoreDependencies.mock()` to `CoreDependencies.live(config: ...)`.
4. Test register, login, token restore, and HTTP 401 logout behavior.
5. Test WebSocket auth, disconnect, reconnect, and re-authentication.
6. Test race state, countdown, ticks, bet confirmation, result, and refund.
7. Test deposit, transaction history, and realtime balance changes.
8. Keep mock mode available for offline tests and feature development.

## Verification

```text
dart format lib test
flutter analyze
flutter test
```
