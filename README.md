# Flutter Horse Racing App

Multi-developer project structured as follows:
- **DEV 1**: Backend (Node.js/WS/REST)
- **DEV 2**: Race Track & Animations (`lib/features/game/widgets/track/**`, `assets/**`)
- **DEV 3**: Betting & Game Loop UI (`lib/features/game/widgets/betting/**`, `lib/features/game/screens/game_screen.dart`)
- **DEV 4**: Wallet & Mock Deposit (`lib/features/wallet/**`)
- **DEV 5**: Auth UI, History, Profile, Audio & App Shell (`lib/features/auth/**`, `lib/features/history/**`, `lib/features/profile/**`, `lib/audio/**`, `lib/app.dart`)
- **DEV 6**: Mobile Core & Integration (`lib/core/**`, `lib/models/**`)

The mobile core is mock-first. Feature teams can develop without the backend,
then switch the composition root to DEV 1's REST and WebSocket services without
changing provider or UI contracts.

See [Mobile Core Integration](docs/mobile-core-integration.md) for bootstrap,
API contracts, backend handoff, and test commands.
