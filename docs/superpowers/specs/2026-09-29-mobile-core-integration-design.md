# Mobile Core and Integration Design

## Context

The Flutter project currently contains placeholders for models and WebSocket
connectivity. The backend is being developed independently by DEV 1, while the
mobile feature developers need stable data contracts immediately.

This design provides the mobile core owned by DEV 6. It lets feature code run
against deterministic mock data first and switch to DEV 1's REST and WebSocket
backend without rewriting screens or providers.

## Goals

- Provide shared models for authentication, racing, betting, transactions,
  payments, and winners.
- Centralize REST endpoints and application configuration.
- Provide injectable REST, storage, and WebSocket boundaries.
- Implement `AuthProvider`, `GameProvider`, and `WalletProvider` as the
  controller/state layer used by feature screens.
- Make mock implementations the initial development mode.
- Make switching to the live backend a dependency configuration change.
- Cover model, service, and provider behavior with automated tests.

## Non-goals

- Implementing or modifying the Node.js backend.
- Building feature UI owned by DEV 2 through DEV 5.
- Implementing real-money payments.
- Duplicating countdown or race simulation logic inside feature screens.

## Architecture

The project follows an MVC-oriented boundary:

- **Model:** immutable domain models and JSON serialization in `lib/models/`.
- **Controller/state:** `ChangeNotifier` providers in `lib/core/providers/`.
- **View:** existing feature screens and widgets owned by the other mobile
  developers.

External I/O is accessed through injectable contracts:

```text
View -> Provider -> ApiClient/SocketService/LocalStorage -> Data source
```

Development mode uses `MockApiClient` and `MockSocketService`. Live mode uses
`HttpApiClient` and `LiveSocketService`. Both implementations expose the same
interfaces, so providers and views do not branch on the active mode.

## Configuration and Composition

`AppConfig` defines the REST URL, WebSocket URL, betting limits, allowed bet
amounts, environment, and data-source mode.

`CoreDependencies` is the composition root for the mobile core:

```dart
CoreDependencies.mock()
CoreDependencies.live()
```

Mock mode is the initial default. After DEV 1's backend is available, app
bootstrap selects live mode. No feature screen changes are required.

## Models

The following immutable models provide `fromJson` and `toJson` behavior:

- `UserModel`
- `HorseModel`
- `RaceStateModel` and `RacePhase`
- `BetModel` and `BetStatus`
- `TransactionModel` and `TransactionType`
- `PaymentOrderModel`
- `WinnerModel`

Existing `user.dart`, `horse.dart`, `race.dart`, and `bet.dart` entry points
remain as compatibility exports or aliases where practical, preventing early
feature work from breaking.

Numeric JSON values accept both integer and floating-point representations.
Required identifiers and event types are validated. Contract differences from
the live backend are isolated in model parsing or a service adapter.

## REST Integration

`ApiEndpoints` is the only source of endpoint paths. It covers authentication,
wallet operations, bet history, race history, and recent winners.

`ApiClient` exposes typed `get` and `post` operations. `HttpApiClient` handles:

- JSON encoding and decoding.
- Bearer token attachment.
- transport failures and timeouts.
- HTTP-to-domain error mapping.
- a centralized callback for HTTP 401.

`MockApiClient` returns deterministic in-memory responses using the same JSON
shape expected from DEV 1. Unsupported mock routes fail explicitly so tests do
not silently pass on incomplete behavior.

## Local Storage

`LocalStorage` persists:

- JWT access token.
- username.
- mute preference.

It exposes focused read, write, and clear methods. Authentication logout clears
identity data without deleting unrelated user preferences. The implementation
uses `shared_preferences`, whose test store can be initialized with mock values.

## WebSocket Integration

`SocketService` exposes:

- connect and disconnect.
- JWT authentication.
- bet placement.
- ping/pong.
- a broadcast stream of parsed `SocketEvent` values.
- bounded automatic reconnect for unexpected disconnections.

The live implementation uses `web_socket_channel`. It decodes the common
envelope `{ "type": "...", "data": { ... } }` and maps malformed messages to
an error event instead of crashing a provider.

The mock implementation provides deterministic race state, countdown, race
ticks, bet confirmation/results, balance updates, cancellation, and refund
events. Tests can inject events directly without real timers or network access.

## Providers

### AuthProvider

Depends on `ApiClient`, `LocalStorage`, and `SocketService`. It exposes
`login`, `register`, `autoLogin`, and `logout`, along with authenticated user,
loading, and error state.

Successful authentication persists the token and username, then connects and
authenticates the socket. A 401 or explicit logout clears identity data and
disconnects the socket.

### GameProvider

Depends on `SocketService` and owns:

- race state and phase.
- countdown.
- horse positions.
- bets for the current round.
- latest bet result.
- loading/error state where applicable.

It listens to the socket's broadcast stream and applies `RACE_STATE`,
`COUNTDOWN`, `RACE_TICK`, `BET_CONFIRMED`, `BET_RESULT`, `RACE_CANCELLED`, and
`BET_REFUNDED`. Placing a bet delegates to `SocketService`; screens do not make
an HTTP request for bets.

### WalletProvider

Depends on `ApiClient` and `SocketService`. It owns cash, transactions,
loading, and error state. It loads transaction history and performs the demo
deposit through REST. It also consumes `BALANCE_UPDATE` and refund-related
socket events so the displayed balance remains current.

## Mock-to-live Transition

Before DEV 1 is ready:

```text
UI -> Providers -> MockApiClient / MockSocketService -> deterministic data
```

After DEV 1 is ready:

```text
UI -> Providers -> HttpApiClient / LiveSocketService -> DEV 1 backend
```

The transition consists of:

1. Set the live REST and WebSocket URLs.
2. Select `CoreDependencies.live()`.
3. Run contract and integration tests against the backend.
4. If payload fields differ, update only model parsing or the relevant adapter.

## Error Handling

Infrastructure errors are represented by stable application exceptions rather
than leaking package-specific errors into providers. Providers catch these
exceptions, update their public error state, and always reset loading state.
Malformed WebSocket events are reported without terminating the broadcast
stream. Reconnect stops after an intentional logout or disconnect.

## Testing

Tests cover:

- JSON round trips and enum fallbacks for all models.
- endpoint constants and HTTP request/error behavior.
- token, username, and mute persistence.
- WebSocket envelope parsing and mock event delivery.
- login, registration, auto-login, logout, and authentication failure.
- race state, countdown, positions, bet confirmation/result, cancellation, and
  refund state transitions.
- transaction loading, mock deposit, live balance updates, empty data, and API
  errors.

Completion requires fresh successful runs of `flutter analyze` and
`flutter test`.

## Ownership and Integration Safety

Implementation is limited to `lib/core/**`, `lib/models/**`, tests, required
dependency declarations, and compatibility updates inside the DEV 6 ownership
area. Feature screens and widgets owned by other developers are not modified.
