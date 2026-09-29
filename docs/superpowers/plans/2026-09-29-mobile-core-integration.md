# Mobile Core and Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a tested mock-first Flutter mobile core that switches to DEV 1's REST and WebSocket backend without changes to feature UI or provider contracts.

**Architecture:** Immutable models define the shared contract, injectable REST/storage/socket boundaries isolate I/O, and `ChangeNotifier` providers form the MVC controller layer. `CoreDependencies.mock()` supplies deterministic local data now, while `CoreDependencies.live()` supplies HTTP and WebSocket implementations later.

**Tech Stack:** Flutter 3.47, Dart 3.13, `http`, `shared_preferences`, `web_socket_channel`, `flutter_test`

**Spec:** `docs/superpowers/specs/2026-09-29-mobile-core-integration-design.md`

## Global Constraints

- Keep feature UI under `lib/features/**` unchanged.
- Keep mock and live implementations behind identical interfaces.
- Use mock mode as the initial default.
- Centralize all route strings in `ApiEndpoints`.
- Bets are sent through `SocketService`, not HTTP.
- Mock deposit is demo-only and never represents real money.
- Preserve compatibility for existing model import paths where practical.

## Review Focus

- Integer and floating-point JSON numbers must both parse without casts failing; Task 1 model tests cover both representations.
- Missing, malformed, or unknown WebSocket envelopes must emit an error event without closing the event stream; Task 4 socket tests cover this.
- HTTP 401 must invoke the unauthorized callback and return a stable `ApiException`; Task 2 client tests cover both effects.
- Explicit logout/disconnect must not trigger automatic WebSocket reconnection; Task 4 tests cover the intentional-disconnect path.
- A provider failure must clear loading state while preserving a user-readable error; Tasks 5 and 7 provider tests cover this.

---

### Task 1: Domain Models and Compatibility Exports

**Files:**
- Create: `lib/models/user_model.dart`
- Create: `lib/models/horse_model.dart`
- Create: `lib/models/race_state_model.dart`
- Create: `lib/models/bet_model.dart`
- Create: `lib/models/transaction_model.dart`
- Create: `lib/models/payment_order_model.dart`
- Create: `lib/models/winner_model.dart`
- Modify: `lib/models/user.dart`
- Modify: `lib/models/horse.dart`
- Modify: `lib/models/race.dart`
- Modify: `lib/models/bet.dart`
- Create: `test/models/models_test.dart`

**Interfaces:**
- Consumes: JSON maps using the field names in the design contract.
- Produces: immutable model classes with `factory fromJson(Map<String, dynamic>)`, `Map<String, dynamic> toJson()`, value equality, `copyWith` where provider state requires updates, plus `RacePhase`, `BetStatus`, and `TransactionType` enums.

- [ ] **Step 1: Write failing model tests**

  Add tests named `models parse int and double numeric values`, `models round trip contract JSON`, `unknown enum values use safe fallbacks`, and `legacy model imports remain constructible`. Assert the exact expected identifiers, cash, odds, amount, phase, status, transaction type, rankings, and JSON keys.

- [ ] **Step 2: Run model tests and confirm red**

  Run: `flutter test test/models/models_test.dart`
  Expected: FAIL because the new model files and APIs do not exist.

- [ ] **Step 3: Implement model files and compatibility entry points**

  Implement the interfaces above. Use shared local parsing helpers only when they eliminate repeated unsafe numeric/date conversions. Legacy files export or typedef the new types without keeping duplicate sources of truth.

- [ ] **Step 4: Run model tests and confirm green**

  Run: `flutter test test/models/models_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit Task 1**

  Commit: `feat: add mobile core domain models`

### Task 2: App Configuration, API Endpoints, and REST Clients

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/config/app_config.dart`
- Create: `lib/core/network/api_endpoints.dart`
- Create: `lib/core/network/api_exception.dart`
- Create: `lib/core/network/api_client.dart`
- Create: `lib/core/network/http_api_client.dart`
- Create: `lib/core/network/mock_api_client.dart`
- Modify: `lib/core/constants/api_constants.dart`
- Create: `test/core/network/api_client_test.dart`
- Create: `test/core/network/mock_api_client_test.dart`

**Interfaces:**
- Consumes: optional token callback `Future<String?> Function()` and unauthorized callback `Future<void> Function()`.
- Produces: `abstract interface class ApiClient` with `Future<Map<String, dynamic>> get(String path)` and `post(String path, {Map<String, dynamic>? body})`; `HttpApiClient`; `MockApiClient`; `ApiException`; `ApiEndpoints`; `AppConfig` and `DataSourceMode`.

- [ ] **Step 1: Add failing REST boundary tests**

  Test endpoint values, URL joining, JSON encoding/decoding, Bearer authorization, success responses, non-JSON responses, transport failure, HTTP error messages, 401 callback behavior, and unsupported mock routes.

- [ ] **Step 2: Run REST tests and confirm red**

  Run: `flutter test test/core/network`
  Expected: FAIL because the REST boundary is not implemented.

- [ ] **Step 3: Add the HTTP dependency and implement configuration/client files**

  Add `http` with Flutter's package manager. Implement all interfaces and deterministic mock routes for auth, transactions, deposit, bet history, race history, and recent winners.

- [ ] **Step 4: Run REST tests and confirm green**

  Run: `flutter test test/core/network`
  Expected: PASS.

- [ ] **Step 5: Commit Task 2**

  Commit: `feat: add mock and live REST clients`

### Task 3: Local Storage

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/storage/local_storage.dart`
- Create: `test/core/storage/local_storage_test.dart`

**Interfaces:**
- Consumes: `SharedPreferencesAsync` or the supported testable shared-preferences API.
- Produces: `LocalStorage` methods `saveToken`, `getToken`, `saveUsername`, `getUsername`, `setMuted`, `isMuted`, and `clearAuth`.

- [ ] **Step 1: Write failing persistence tests**

  Assert token and username round trips, mute defaults to false, mute survives `clearAuth`, and `clearAuth` removes only authentication values.

- [ ] **Step 2: Run storage tests and confirm red**

  Run: `flutter test test/core/storage/local_storage_test.dart`
  Expected: FAIL because `LocalStorage` does not exist.

- [ ] **Step 3: Add shared preferences and implement `LocalStorage`**

  Add `shared_preferences` with Flutter's package manager and use an injectable/testable preferences instance.

- [ ] **Step 4: Run storage tests and confirm green**

  Run: `flutter test test/core/storage/local_storage_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit Task 3**

  Commit: `feat: add mobile local storage`

### Task 4: Socket Contract, Live Socket, and Mock Socket

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/socket/socket_event.dart`
- Create: `lib/core/socket/socket_service.dart`
- Create: `lib/core/socket/live_socket_service.dart`
- Create: `lib/core/socket/mock_socket_service.dart`
- Modify: `lib/core/network/websocket_client.dart`
- Create: `test/core/socket/socket_service_test.dart`

**Interfaces:**
- Consumes: WebSocket envelopes `{type, data}` and injectable channel connector/reconnect timing.
- Produces: `SocketEvent`; `abstract interface class SocketService` with `Stream<SocketEvent> get events`, `bool get isConnected`, `connect`, `disconnect`, `authenticate(String token)`, `placeBet({required String raceId, required String horseId, required double amount})`, `ping`, and `dispose`; live and mock implementations.

- [ ] **Step 1: Write failing socket tests**

  Assert envelope parsing, broadcast delivery to multiple listeners, AUTH/PLACE_BET/PING payloads, mock event injection, malformed-event recovery, unexpected-close reconnect, and no reconnect after explicit disconnect.

- [ ] **Step 2: Run socket tests and confirm red**

  Run: `flutter test test/core/socket/socket_service_test.dart`
  Expected: FAIL because the socket contract does not exist.

- [ ] **Step 3: Add WebSocket dependency and implement socket files**

  Add `web_socket_channel`. Implement bounded exponential reconnect with injectable delay, retain the last JWT for reconnect authentication, and cancel all timers/subscriptions in `dispose`.

- [ ] **Step 4: Run socket tests and confirm green**

  Run: `flutter test test/core/socket/socket_service_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit Task 4**

  Commit: `feat: add mock and live socket services`

### Task 5: Authentication Provider

**Files:**
- Create: `lib/core/providers/auth_provider.dart`
- Create: `test/core/providers/auth_provider_test.dart`

**Interfaces:**
- Consumes: `ApiClient`, `LocalStorage`, `SocketService`, auth response fields `token` and `user`.
- Produces: `AuthProvider` getters `user`, `isAuthenticated`, `isLoading`, and `error`; methods `login({required String username, required String password})`, `register({required String fullName, required String username, required String password})`, `autoLogin()`, and `logout()`.

- [ ] **Step 1: Write failing auth-provider tests**

  Assert successful login/register persistence and socket auth, failed login error/loading state, auto-login with and without a token, and logout storage/socket cleanup.

- [ ] **Step 2: Run auth tests and confirm red**

  Run: `flutter test test/core/providers/auth_provider_test.dart`
  Expected: FAIL because `AuthProvider` does not exist.

- [ ] **Step 3: Implement `AuthProvider`**

  Use one private authentication-response handler for login/register, notify listeners after observable changes, and convert infrastructure exceptions to public error text.

- [ ] **Step 4: Run auth tests and confirm green**

  Run: `flutter test test/core/providers/auth_provider_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit Task 5**

  Commit: `feat: add authentication provider`

### Task 6: Game Provider

**Files:**
- Create: `lib/core/providers/game_provider.dart`
- Create: `test/core/providers/game_provider_test.dart`

**Interfaces:**
- Consumes: `SocketService.events`, `RaceStateModel`, `BetModel`, and race/bet event payloads.
- Produces: `GameProvider` getters `raceState`, `phase`, `countdown`, `positions`, `myBetsThisRound`, `lastBetResult`, and `error`; methods `placeBet`, `clearLastBetResult`, and `dispose`.

- [ ] **Step 1: Write failing game-provider tests**

  Assert initial mock-friendly state and transitions for `RACE_STATE`, `COUNTDOWN`, `RACE_TICK`, `BET_CONFIRMED`, `BET_RESULT`, `RACE_CANCELLED`, `BET_REFUNDED`, and invalid payload errors. Assert `placeBet` delegates to the socket with exact values.

- [ ] **Step 2: Run game tests and confirm red**

  Run: `flutter test test/core/providers/game_provider_test.dart`
  Expected: FAIL because `GameProvider` does not exist.

- [ ] **Step 3: Implement `GameProvider`**

  Subscribe once in the constructor, keep event handling in focused private methods, expose unmodifiable collections, and cancel the subscription during disposal.

- [ ] **Step 4: Run game tests and confirm green**

  Run: `flutter test test/core/providers/game_provider_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit Task 6**

  Commit: `feat: add realtime game provider`

### Task 7: Wallet Provider and Dependency Composition

**Files:**
- Create: `lib/core/providers/wallet_provider.dart`
- Create: `lib/core/bootstrap/core_dependencies.dart`
- Create: `test/core/providers/wallet_provider_test.dart`
- Create: `test/core/bootstrap/core_dependencies_test.dart`

**Interfaces:**
- Consumes: `ApiClient`, `SocketService`, `LocalStorage`, transaction/deposit payloads, and `BALANCE_UPDATE` events.
- Produces: `WalletProvider` getters `cash`, `transactions`, `isLoading`, and `error`; methods `loadTransactions()` and `mockDeposit(double amount)`; `CoreDependencies.mock()` and `CoreDependencies.live()` factories exposing shared client, storage, socket, and provider instances.

- [ ] **Step 1: Write failing wallet and composition tests**

  Assert empty/success/error transaction loads, successful deposit updates cash and transactions, invalid deposit rejection, realtime balance updates, provider loading reset after failures, mock composition types, and live composition types/configuration.

- [ ] **Step 2: Run wallet/composition tests and confirm red**

  Run: `flutter test test/core/providers/wallet_provider_test.dart test/core/bootstrap/core_dependencies_test.dart`
  Expected: FAIL because the wallet provider and composition root do not exist.

- [ ] **Step 3: Implement wallet provider and composition root**

  Accept only positive demo-deposit amounts, expose unmodifiable transactions, and ensure all providers share the same socket instance.

- [ ] **Step 4: Run wallet/composition tests and confirm green**

  Run: `flutter test test/core/providers/wallet_provider_test.dart test/core/bootstrap/core_dependencies_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit Task 7**

  Commit: `feat: compose mock-first mobile core`

### Task 8: Full Verification and Developer Handoff

**Files:**
- Modify: `README.md`
- Create: `docs/mobile-core-integration.md`

**Interfaces:**
- Consumes: completed model, REST, storage, socket, provider, and composition APIs.
- Produces: setup examples for mock mode, live mode, provider wiring, backend contract checklist, and test commands.

- [ ] **Step 1: Document mock and live bootstrap**

  Show exact `CoreDependencies.mock()` and `CoreDependencies.live()` usage, required DEV 1 endpoint/event fields, Android emulator localhost guidance, and the mock-to-live checklist.

- [ ] **Step 2: Format source and tests**

  Run: `dart format lib test`
  Expected: command succeeds with no formatting errors.

- [ ] **Step 3: Run static analysis**

  Run: `flutter analyze`
  Expected: `No issues found!`

- [ ] **Step 4: Run the complete test suite**

  Run: `flutter test`
  Expected: all tests pass.

- [ ] **Step 5: Check the final diff and commit handoff docs**

  Run: `git diff --check` and `git status --short`.
  Commit: `docs: add mobile core integration guide`
