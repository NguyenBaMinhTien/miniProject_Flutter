# 🐎 PHÂN CÔNG TASK TEAM 5 DEV — FLUTTER HORSE RACING APP

> **Cơ cấu team**
>
> - **DEV 1:** Mobile Flutter + Backend
> - **DEV 2:** Mobile Flutter — Race Track & Animation
> - **DEV 3:** Mobile Flutter — Betting & Game Loop
> - **DEV 4:** Mobile Flutter — Wallet & Mock Deposit
> - **DEV 5:** Mobile Flutter — Auth UI, History, Profile, Audio & App Shell
>
> Mục tiêu của cách chia này là **không để DEV 1 bị ôm toàn bộ Mobile + Backend**. DEV 1 chịu trách nhiệm backend, contract API/WebSocket và tầng kết nối Flutter. Bốn Mobile Dev còn lại tập trung vào UI/UX và feature.

---

# 1. NGUYÊN TẮC CHIA VIỆC

## 1.1. Quy tắc ownership

Mỗi file/module chỉ có **một owner chính**.

| Module | Owner |
|---|---|
| Backend API / WebSocket / Game Engine | DEV 1 |
| Flutter Core Network / Socket / Models | DEV 1 |
| Race Track / Horse Animation | DEV 2 |
| Betting / Game Loop UI | DEV 3 |
| Wallet / Mock Deposit | DEV 4 |
| Auth UI / History / Profile / Audio / Bottom Navigation | DEV 5 |

Không để DEV 2 và DEV 3 cùng sửa `game_screen.dart`.

- DEV 2 chỉ export `RaceTrackWidget`.
- DEV 3 là owner của `GameScreen`.
- DEV 5 là owner của `MainAppShell` / `BottomNavigationBar`.
- DEV 1 cung cấp provider/service/interface để các Mobile Dev sử dụng.

---

# 2. KIẾN TRÚC PHÂN CÔNG

```text
                         ┌──────────────────────────┐
                         │          DEV 1           │
                         │    MOBILE + BACKEND      │
                         │                          │
                         │ Backend REST API         │
                         │ WebSocket Server         │
                         │ Game Engine              │
                         │ Auth / Wallet API        │
                         │ Flutter API Client       │
                         │ Flutter SocketService    │
                         │ Models / Providers       │
                         └─────────────┬────────────┘
                                       │
                    API + WS Contract  │
                                       │
          ┌────────────────────────────┼───────────────────────────┐
          │                            │                           │
          ▼                            ▼                           ▼
┌─────────────────┐         ┌──────────────────┐        ┌──────────────────┐
│      DEV 2      │         │      DEV 3       │        │      DEV 4       │
│ MOBILE FLUTTER  │         │ MOBILE FLUTTER   │        │ MOBILE FLUTTER   │
│                 │         │                  │        │                  │
│ Race Track      │         │ Betting          │        │ Wallet           │
│ Horse Animation │         │ Countdown        │        │ Mock Deposit     │
│ Winner Effects  │         │ GameScreen       │        │ Transactions     │
└────────┬────────┘         └─────────┬────────┘        └─────────┬────────┘
         │                            │                            │
         └──────────────┬─────────────┴──────────────┬─────────────┘
                        │                            │
                        ▼                            ▼
                ┌────────────────────────────────────────┐
                │                 DEV 5                  │
                │            MOBILE FLUTTER              │
                │                                        │
                │ Auth UI / History / Profile / Audio    │
                │ Main App Shell / Bottom Navigation     │
                │ Responsive / UI Polish                 │
                └────────────────────────────────────────┘
```

---

# 3. DEV 1 — MOBILE + BACKEND

## Vai trò

DEV 1 là người duy nhất phụ trách Backend nên **không nhận nhiều màn hình UI**.

DEV 1 chịu trách nhiệm:

1. Backend API.
2. WebSocket server.
3. Game engine.
4. Database/service backend.
5. Flutter network layer.
6. Flutter SocketService.
7. Models.
8. Providers dùng chung.
9. API/WS contract cho toàn team.

---

## 3.1. Backend Tasks

### BE-01 — Khởi tạo Backend

- Setup project backend.
- Environment config.
- CORS.
- JSON middleware.
- Error handler.
- Logging.
- Health check.

### BE-02 — Auth API

Các endpoint:

```http
POST /api/auth/register
POST /api/auth/login
GET  /api/auth/me
```

Yêu cầu:

- Register.
- Login.
- JWT.
- Validate token.
- User role: `user | admin`.
- Response format thống nhất cho Flutter.

---

### BE-03 — User & Wallet

Data chính:

```text
User
- id
- username
- fullName
- passwordHash
- role
- cash
- createdAt
```

API:

```http
GET /api/wallet
GET /api/wallet/transactions
POST /api/wallet/deposit-mock
```

---

### BE-04 — Transaction Engine

Các loại transaction:

```text
BET
WIN
REFUND
MOCK_DEPOSIT
ADMIN_ADJUST
```

Mỗi transaction cần lưu:

```text
id
userId
type
cashDelta
cashAfter
description
createdAt
```

---

### BE-05 — Horse Configuration

Server quản lý danh sách 5 ngựa:

| # | Horse | Odds |
|---|---|---:|
| 1 | Xích Thố | 2.2x |
| 2 | Bạch Long | 3.0x |
| 3 | Kim Quy | 4.0x |
| 4 | Hắc Báo | 5.5x |
| 5 | Thanh Long | 7.0x |

Server là nguồn dữ liệu chính.

Flutter chỉ render dữ liệu server trả về.

---

### BE-06 — Race State Machine

Các phase:

```text
BETTING
    ↓
RACING
    ↓
FINISHED
    ↓
BETTING
```

Trường hợp lỗi:

```text
BETTING
    ↓
CANCELLED
    ↓
BETTING
```

---

### BE-07 — Countdown Engine

Ví dụ:

```text
BETTING   = 15 giây
RACING    = khoảng 10-15 giây
FINISHED  = 8 giây
CANCELLED = 5 giây
```

Server là nguồn thời gian chính.

Flutter **không tự quyết định phase**.

---

### BE-08 — Race Engine

Server xử lý:

- Vị trí 5 ngựa.
- Tick mỗi `100ms`.
- Winner.
- Rankings.
- Kết thúc race.
- Không cho client tự tính winner.

Event:

```text
RACE_TICK
```

Payload:

```json
{
  "positions": [18.4, 22.1, 15.8, 25.2, 19.7],
  "leaderId": 4
}
```

---

### BE-09 — Betting Engine

Client gửi:

```text
PLACE_BET
```

Server validate:

- User đã login.
- Phase hiện tại = BETTING.
- Horse tồn tại.
- Amount hợp lệ.
- User đủ balance.
- Không vượt giới hạn.
- Không nhận cược khi race đã khóa.

Sau khi thành công:

```text
BET_CONFIRMED
BALANCE_UPDATE
```

---

### BE-10 — Settlement Engine

Khi race kết thúc:

```text
winner
↓
tìm tất cả bet
↓
tính WON / LOST
↓
tính payout
↓
update wallet
↓
ghi transaction
↓
gửi BET_RESULT
```

---

### BE-11 — Race Cancellation & Refund

Nếu race bị hủy:

```text
RACE_CANCELLED
```

Server:

- Đánh dấu race cancelled.
- Hoàn 100% bet.
- Ghi transaction `REFUND`.
- Gửi `BET_REFUNDED`.
- Gửi `BALANCE_UPDATE`.

---

### BE-12 — History API

```http
GET /api/game/my-bets
GET /api/game/history
GET /api/game/recent-winners
```

---

### BE-13 — WebSocket Server

Client → Server:

```text
AUTH
PLACE_BET
PING
```

Server → Client:

```text
WELCOME
AUTH_SUCCESS
RACE_STATE
COUNTDOWN
RACE_TICK
RACE_FINISHED
BET_CONFIRMED
BET_RESULT
BALANCE_UPDATE
RACE_CANCELLED
BET_REFUNDED
ERROR
PONG
```

---

## 3.2. Flutter Tasks của DEV 1

### MBE-01 — Models

Owner:

```text
lib/models/
```

Files:

```text
user_model.dart
horse_model.dart
race_state_model.dart
bet_model.dart
transaction_model.dart
payment_order_model.dart
winner_model.dart
```

---

### MBE-02 — AppConfig

```text
lib/core/config/app_config.dart
```

Chứa:

```text
baseUrl
wsUrl
minBet
maxBet
betAmounts
environment
```

---

### MBE-03 — ApiClient

```text
lib/core/network/api_client.dart
```

Chức năng:

- GET.
- POST.
- Authorization Bearer Token.
- JSON encode/decode.
- Error mapping.
- 401 handling.

---

### MBE-04 — ApiEndpoints

```text
lib/core/network/api_endpoints.dart
```

DEV khác **không hard-code endpoint trong screen**.

---

### MBE-05 — LocalStorage

```text
lib/core/storage/local_storage.dart
```

Lưu:

- JWT.
- Username.
- Mute setting nếu cần.

---

### MBE-06 — SocketService

```text
lib/core/socket/socket_service.dart
```

Chức năng:

- Connect.
- Disconnect.
- AUTH.
- Auto reconnect.
- PING/PONG.
- Parse WS event.
- Broadcast streams.

---

### MBE-07 — AuthProvider

```text
lib/core/providers/auth_provider.dart
```

Methods:

```text
login()
register()
autoLogin()
logout()
```

DEV 5 sẽ dùng provider này để làm Login/Register UI.

---

### MBE-08 — GameProvider

```text
lib/core/providers/game_provider.dart
```

State:

```text
raceState
phase
countdown
positions
myBetsThisRound
lastBetResult
```

---

### MBE-09 — WalletProvider

```text
lib/core/providers/wallet_provider.dart
```

State:

```text
cash
transactions
isLoading
error
```

Methods:

```text
loadTransactions()
mockDeposit()
```

---

## Definition of Done — DEV 1

Backend chạy được flow:

```text
Register
→ Login
→ JWT
→ WebSocket AUTH
→ RACE_STATE
→ PLACE_BET
→ RACE_TICK
→ RACE_FINISHED
→ BET_RESULT
→ BALANCE_UPDATE
```

Flutter Mobile có thể connect backend qua:

```text
ApiClient
SocketService
AuthProvider
GameProvider
WalletProvider
```

---

# 4. DEV 2 — MOBILE: RACE TRACK & ANIMATION

## Scope

```text
lib/features/game/widgets/track/
assets/images/horses/
assets/images/track/
assets/animations/
```

---

### M2-01 — Horse Assets

Chuẩn bị 5 ngựa:

```text
horse_1_red
horse_2_blue
horse_3_gold
horse_4_purple
horse_5_green
```

---

### M2-02 — Track Assets

- Track background.
- Finish flag.
- Confetti.
- Dust trail.

---

### M2-03 — HorseSprite

```text
horse_sprite.dart
```

Input:

```dart
color
isRunning
isWinner
```

---

### M2-04 — DustEffect

```text
dust_effect.dart
```

Chỉ chạy khi:

```text
phase == RACING
```

---

### M2-05 — FinishLine

```text
finish_line.dart
```

---

### M2-06 — HorseLaneWidget

```text
horse_lane_widget.dart
```

Input:

```text
HorseModel horse
double position
RacePhase phase
```

---

### M2-07 — Smooth Race Tick

Backend gửi tick mỗi:

```text
100ms
```

Mobile dùng:

```text
TweenAnimationBuilder
AnimatedPositioned
```

Không giật frame.

---

### M2-08 — RaceTrackWidget

```text
race_track_widget.dart
```

Render:

```text
Lane 1
Lane 2
Lane 3
Lane 4
Lane 5
Finish Line
```

---

### M2-09 — WinnerCelebration

```text
winner_celebration.dart
```

Hiệu ứng:

- Confetti.
- Winner name.
- Winner horse.
- Scale animation.
- Auto close.

---

### M2-10 — Mock Data Test

Trước khi backend xong, test bằng:

```dart
positions = [10, 20, 30, 40, 50];
```

Sau đó chỉ thay input bằng `GameProvider`.

---

## Definition of Done — DEV 2

DEV 3 có thể sử dụng:

```dart
RaceTrackWidget(
  horses: ...,
  positions: ...,
  phase: ...,
)
```

DEV 3 không cần biết animation bên trong hoạt động thế nào.

---

# 5. DEV 3 — MOBILE: BETTING & GAME LOOP UI

## Scope

```text
lib/features/game/widgets/betting/
lib/features/game/widgets/countdown/
lib/features/game/screens/game_screen.dart
```

DEV 3 là **owner duy nhất của `GameScreen`**.

---

### M3-01 — PhaseBanner

Hiển thị:

```text
BETTING   → ĐANG MỞ CƯỢC
RACING    → ĐANG ĐUA
FINISHED  → KẾT QUẢ
CANCELLED → ĐÃ HỦY
```

---

### M3-02 — CountdownTimer

Hiển thị countdown từ:

```text
GameProvider.countdown
```

Không tự tạo game countdown độc lập.

---

### M3-03 — HorseBetCard

Hiển thị:

- Number.
- Horse name.
- Odds.
- Selected state.
- Disabled state.

---

### M3-04 — HorseCardList

Danh sách 5 ngựa.

State local:

```text
selectedHorseId
```

---

### M3-05 — ChipSelector

Các mức cược:

```text
100
200
500
1000
2000
5000
10000
```

---

### M3-06 — BetConfirmButton

Validate:

```text
selectedHorse != null
selectedAmount != null
phase == BETTING
balance >= amount
```

---

### M3-07 — PLACE_BET Integration

Không gọi HTTP.

Đặt cược qua:

```dart
SocketService.placeBet(...)
```

---

### M3-08 — BET_CONFIRMED

Sau khi backend confirm:

- Show success.
- Add ticket vào current round.
- Update cash.

---

### M3-09 — MyBetsOverlay

Hiển thị cược trong vòng hiện tại.

Ví dụ:

```text
#2 Bạch Long
2,000đ
Odds 3.0x
Potential 6,000đ
```

---

### M3-10 — ResultPopup

`BET_RESULT`:

```text
WON
LOST
```

Hiển thị payout nếu thắng.

---

### M3-11 — RaceCancelledDialog

Khi nhận:

```text
RACE_CANCELLED
```

Hiển thị:

```text
Phiên đã bị hủy.
Tiền cược sẽ được hoàn lại 100%.
```

---

### M3-12 — GameScreen

Layout:

```text
WinnersTicker
PhaseBanner
CountdownTimer
RaceTrackWidget
HorseCardList
ChipSelector
BetConfirmButton
MyBetsOverlay
```

---

### M3-13 — Phase UI Logic

#### BETTING

```text
Track đứng yên
Hiện betting UI
Cho phép đặt cược
```

#### RACING

```text
Track chạy
Khóa cược
Ẩn ChipSelector
Ẩn Bet button
```

#### FINISHED

```text
Track giữ final position
WinnerCelebration
ResultPopup
```

#### CANCELLED

```text
RaceCancelledDialog
Không cho đặt cược
```

---

## Definition of Done — DEV 3

Flow hoàn chỉnh:

```text
Chọn ngựa
→ chọn amount
→ PLACE_BET
→ BET_CONFIRMED
→ RACING
→ FINISHED
→ BET_RESULT
```

---

# 6. DEV 4 — MOBILE: WALLET & MOCK DEPOSIT

## Scope

```text
lib/features/wallet/
```

**Không dùng tiền thật.**

Toàn bộ deposit là mock/demo.

---

### M4-01 — BalanceCard

Hiển thị:

```text
Số dư khả dụng
50,000đ
```

Data:

```text
WalletProvider.cash
```

---

### M4-02 — DepositAmountPicker

Các package test:

```text
10,000
20,000
50,000
100,000
200,000
500,000
```

---

### M4-03 — QuickMockDeposit

Flow:

```text
Select amount
→ NẠP NGAY
→ POST /api/wallet/deposit-mock
→ update wallet
```

---

### M4-04 — VietQR Mock UI

Chỉ dùng để demo UX.

Không thực hiện giao dịch ngân hàng thật.

---

### M4-05 — DepositBottomSheet

Tabs:

```text
Nạp nhanh
QR mô phỏng
```

---

### M4-06 — TransactionList

Hiển thị:

```text
BET       -2,000đ
WIN       +6,000đ
REFUND    +2,000đ
DEPOSIT   +50,000đ
```

---

### M4-07 — WalletScreen

Layout:

```text
BalanceCard
Deposit Button
TransactionList
```

---

### M4-08 — BALANCE_UPDATE Integration

Ví phải update realtime khi:

```text
đặt cược
thắng cược
refund
mock deposit
```

---

### M4-09 — Wallet State

Phải có:

```text
Loading
Success
Empty
Error
```

---

## Definition of Done — DEV 4

Flow:

```text
Wallet
→ Mock Deposit
→ Balance tăng
→ Transaction xuất hiện
→ Đặt cược
→ Balance giảm realtime
→ Win/Refund
→ Balance tăng realtime
```

---

# 7. DEV 5 — MOBILE: AUTH UI + HISTORY + PROFILE + AUDIO + APP SHELL

DEV 5 nhận các module Mobile còn lại để giảm tải cho DEV 1.

## Scope

```text
lib/features/auth/
lib/features/history/
lib/features/profile/
lib/features/game/widgets/leaderboard/
lib/audio/
lib/app.dart
```

---

## 7.1. Auth UI

### M5-01 — SplashScreen

Flow:

```text
App mở
→ AuthProvider.autoLogin()
→ success → MainAppShell
→ fail → Login
```

---

### M5-02 — LoginScreen

Form:

```text
username
password
Đăng nhập
```

Gọi:

```dart
authProvider.login(...)
```

DEV 5 **không tự viết API login**.

---

### M5-03 — RegisterScreen

Form:

```text
fullName
username
password
confirmPassword
```

Gọi:

```dart
authProvider.register(...)
```

---

## 7.2. History

### M5-04 — BetHistoryCard

State:

```text
PENDING
WON
LOST
REFUNDED
```

---

### M5-05 — RaceHistoryCard

Hiển thị:

```text
raceNumber
winner
rankings
total bet
time
```

---

### M5-06 — HistoryScreen

2 tabs:

```text
Vé cược của tôi
Lịch sử đua
```

API do DEV 1 cung cấp.

---

## 7.3. Profile

### M5-07 — StatsCard

Hiển thị:

```text
totalBets
totalWon
totalLost
winRate
```

---

### M5-08 — SettingsTile

Settings:

```text
Sound
Vibration
```

---

### M5-09 — ProfileScreen

Layout:

```text
Avatar
Username
Join Date
StatsCard
Settings
Logout
```

---

### M5-10 — Logout

Gọi:

```dart
authProvider.logout()
```

Sau đó:

```text
MainAppShell
→ LoginScreen
```

---

## 7.4. Audio

### M5-11 — Audio Assets

Các sound:

```text
countdown_beep
race_start_horn
galloping_loop
crowd_cheer
win_fanfare
lose_buzzer
chip_place
cash_register
button_tap
```

---

### M5-12 — AudioManager

Methods:

```text
playCountdownBeep()
playRaceStart()
startGalloping()
stopGalloping()
playCrowdCheer()
playWinFanfare()
playLoseBuzzer()
playChipPlace()
playCashRegister()
playButtonTap()
```

---

### M5-13 — Game Audio Binding

Events:

```text
COUNTDOWN <= 3
→ countdown beep

BETTING → RACING
→ horn + galloping

RACING → FINISHED
→ stop galloping + crowd

BET_RESULT won
→ win sound

BET_RESULT lost
→ lose sound
```

---

## 7.5. App Shell

### M5-14 — MainAppShell

Bottom navigation:

```text
Game
Wallet
History
Profile
```

DEV 5 chỉ import screens của DEV 3 và DEV 4.

Không sửa code bên trong feature của họ.

---

### M5-15 — Responsive & Polish

Test:

- Android phone nhỏ.
- Android phone chuẩn.
- iPhone.
- Tablet cơ bản.

Fix:

- Overflow.
- Padding.
- Font.
- SafeArea.
- Keyboard.
- Loading.
- Empty state.
- Error state.

---

## Definition of Done — DEV 5

Flow:

```text
Splash
→ Login/Register
→ MainAppShell
→ Game
→ Wallet
→ History
→ Profile
→ Logout
```

Audio hoạt động theo game events.

---

# 8. LỊCH SPRINT ĐỀ XUẤT — 5 NGÀY

| Ngày | DEV 1 — Mobile + BE | DEV 2 — Mobile | DEV 3 — Mobile | DEV 4 — Mobile | DEV 5 — Mobile |
|---|---|---|---|---|---|
| **Day 1** | Backend setup, DB/model, Auth API, Flutter Models/API Client | Horse/track assets, HorseSprite | PhaseBanner, Countdown, HorseBetCard | BalanceCard, DepositPicker | Splash/Login/Register UI |
| **Day 2** | WebSocket, Race Engine, SocketService | Lane, FinishLine, Dust, smooth tick | HorseList, ChipSelector, BetButton | Mock Deposit, DepositSheet | History UI |
| **Day 3** | Betting/Settlement/Refund, Providers | RaceTrackWidget, WinnerCelebration | MyBets, ResultPopup, GameScreen | TransactionList, WalletScreen | Profile, AudioManager |
| **Day 4** | History APIs + backend integration + fix contract | Ghép track với GameProvider | Ghép full game với backend | Ghép wallet với backend | MainAppShell + audio binding |
| **Day 5** | E2E + backend bug fix | E2E + animation fix | E2E + betting fix | E2E + wallet fix | Responsive + E2E + UI polish |

---

# 9. THỨ TỰ ƯU TIÊN

## P0 — Bắt buộc

```text
Auth
WebSocket
Race State
Race Tick
Bet
Settlement
Balance
GameScreen
Wallet
```

## P1 — Nên hoàn thành

```text
History
Profile
Audio
Winner animation
Mock Deposit
```

## P2 — Polish

```text
Confetti
Dust
Advanced animation
VietQR mock
Marquee winner ticker
Tablet polish
```

Nếu sprint bị trễ:

> Cắt P2 trước. Không cắt P0.

---

# 10. DEPENDENCY GIỮA 5 DEV

```text
DEV 1
 │
 ├── Models ───────────────► DEV 2
 │
 ├── GameProvider ─────────► DEV 2
 │                         ► DEV 3
 │
 ├── SocketService ────────► DEV 3
 │
 ├── WalletProvider ───────► DEV 4
 │
 └── AuthProvider/API ─────► DEV 5

DEV 2
 └── RaceTrackWidget ──────► DEV 3

DEV 3
 └── GameScreen ───────────► DEV 5 MainAppShell

DEV 4
 └── WalletScreen ─────────► DEV 5 MainAppShell

DEV 5
 └── MainAppShell ghép toàn bộ app
```

---

# 11. QUY TẮC GIT ĐỂ KHÔNG CONFLICT

Branches:

```text
develop

feature/dev1-backend
feature/dev1-mobile-core

feature/dev2-race-track

feature/dev3-betting

feature/dev4-wallet

feature/dev5-auth-history-profile
```

Không push trực tiếp vào:

```text
main
```

Flow:

```text
feature branch
→ Pull Request
→ develop
→ E2E
→ main
```

---

# 12. FILE OWNERSHIP

## DEV 1

```text
backend/**

lib/core/**
lib/models/**
```

## DEV 2

```text
lib/features/game/widgets/track/**
assets/images/horses/**
assets/images/track/**
assets/animations/**
```

## DEV 3

```text
lib/features/game/widgets/betting/**
lib/features/game/widgets/countdown/**
lib/features/game/screens/game_screen.dart
```

## DEV 4

```text
lib/features/wallet/**
```

## DEV 5

```text
lib/features/auth/**
lib/features/history/**
lib/features/profile/**
lib/features/game/widgets/leaderboard/**
lib/audio/**
lib/app.dart
```

---

# 13. QUY TẮC API CONTRACT

DEV 1 phải chốt contract trước khi team ghép code.

Ví dụ:

```json
{
  "type": "BET_CONFIRMED",
  "data": {
    "id": "bet_001",
    "raceId": "race_596",
    "horseId": 2,
    "horseName": "Bạch Long",
    "odds": 3.0,
    "amount": 2000,
    "potentialPayout": 6000,
    "cash": 48000
  }
}
```

Mobile **không tự đổi tên field**.

Nếu contract cần thay đổi:

```text
DEV 1 update contract
→ báo team
→ update model
→ Mobile Dev mới sửa feature
```

---

# 14. MOCK-FIRST ĐỂ 4 MOBILE DEV KHÔNG PHẢI CHỜ BACKEND

Trong Day 1-2:

DEV 2:

```dart
positions = [10, 20, 30, 40, 50];
```

DEV 3:

```dart
horses = HorseModel.defaults;
countdown = 15;
phase = RacePhase.betting;
```

DEV 4:

```dart
cash = 50000;
transactions = [];
```

DEV 5:

```dart
fakeUser = UserModel(...);
```

Khi DEV 1 hoàn thành provider:

```text
Mock Data
   ↓
Provider Data
```

UI không phải viết lại.

---

# 15. FLOW E2E CUỐI SPRINT

```text
START
  ↓
Splash
  ↓
Login / Register
  ↓
MainAppShell
  ↓
Game
  ↓
BETTING
  ↓
Chọn Horse
  ↓
Chọn Amount
  ↓
PLACE_BET
  ↓
BET_CONFIRMED
  ↓
Balance giảm
  ↓
RACING
  ↓
RACE_TICK
  ↓
FINISHED
  ↓
BET_RESULT
  ↓
Balance update
  ↓
History
  ↓
Wallet
  ↓
Profile
  ↓
Logout
  ↓
Login
```

---

# 16. TEST CASE CHIA THEO DEV

## DEV 1

- JWT hết hạn.
- Socket disconnect.
- Auto reconnect.
- Bet ngoài phase.
- Bet vượt balance.
- Double bet request.
- Settlement.
- Refund.
- Race cancellation.

## DEV 2

- Position 0.
- Position 100.
- Tick liên tục.
- Winner animation.
- Race restart.
- FPS không giật.

## DEV 3

- Chưa chọn horse.
- Chưa chọn amount.
- Insufficient balance.
- Countdown = 0.
- BET_CONFIRMED.
- BET_RESULT.
- CANCELLED.

## DEV 4

- Empty transaction.
- Mock deposit.
- Balance update.
- Transaction refresh.
- API error.

## DEV 5

- Auto login.
- Login fail.
- Register validation.
- Logout.
- Empty history.
- Audio mute.
- Responsive.

---

# 17. DEFINITION OF DONE TOÀN TEAM

Project chỉ xem là hoàn thành khi test được:

```text
1. Register.
2. Login.
3. Auto login.
4. WebSocket connect.
5. Race state realtime.
6. Countdown realtime.
7. Đặt cược.
8. Trừ balance.
9. Race animation.
10. Winner.
11. Settlement.
12. Win/Lose popup.
13. Refund khi cancel.
14. Mock deposit.
15. Transaction history.
16. Bet history.
17. Race history.
18. Profile.
19. Sound toggle.
20. Logout.
21. Socket reconnect.
22. Responsive không overflow.
```

---

# 18. TÓM TẮT KHỐI LƯỢNG

| Dev | Role | Khối lượng chính |
|---|---|---|
| **DEV 1** | **Mobile + Backend** | Backend, API, WS, Race Engine, Auth, Settlement, Flutter Core |
| **DEV 2** | Mobile | Race Track + Animation |
| **DEV 3** | Mobile | Betting + Game Loop + GameScreen |
| **DEV 4** | Mobile | Wallet + Mock Deposit + Transaction |
| **DEV 5** | Mobile | Auth UI + History + Profile + Audio + Navigation |

Điểm quan trọng nhất:

> **DEV 1 không làm toàn bộ Mobile.**
>
> DEV 1 tập trung Backend + tầng kết nối Mobile.
>
> Bốn DEV Mobile còn lại chịu trách nhiệm feature UI và tích hợp thông qua interface/provider do DEV 1 cung cấp.
