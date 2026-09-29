// DEV 5 Scope: Auth UI, History, Profile, Audio & App Shell
import 'package:flutter/material.dart';

import '../widgets/bet_history_card.dart';
import '../widgets/race_history_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    this.betHistory,
    this.raceHistory,
  });

  final List<BetHistoryData>? betHistory;
  final List<RaceHistoryData>? raceHistory;

  // TODO(DEV1-INTEGRATION):
  // Replace mock history data with provider/API data.
  static const _mockBets = <BetHistoryData>[
    BetHistoryData(
      horseName: 'Midnight Comet',
      raceNumber: 8,
      betAmount: 40,
      odds: 3.2,
      payout: 128,
      status: BetHistoryStatus.won,
      placedAt: 'Sep 29, 2026 • 7:42 PM',
    ),
    BetHistoryData(
      horseName: 'Golden Arrow',
      raceNumber: 6,
      betAmount: 25,
      odds: 2.6,
      payout: 0,
      status: BetHistoryStatus.lost,
      placedAt: 'Sep 28, 2026 • 6:15 PM',
    ),
    BetHistoryData(
      horseName: 'Silver Tempest',
      raceNumber: 11,
      betAmount: 30,
      odds: 4.1,
      payout: 123,
      status: BetHistoryStatus.pending,
      placedAt: 'Sep 30, 2026 • 8:05 PM',
    ),
    BetHistoryData(
      horseName: 'Emerald Dash',
      raceNumber: 3,
      betAmount: 20,
      odds: 2.9,
      payout: 20,
      status: BetHistoryStatus.refunded,
      placedAt: 'Sep 27, 2026 • 4:30 PM',
    ),
  ];

  static const _mockRaces = <RaceHistoryData>[
    RaceHistoryData(
      raceNumber: 8,
      winner: 'Midnight Comet',
      rankings: ['Midnight Comet', 'Rapid Echo', 'Golden Arrow'],
      totalBet: 2860,
      racedAt: 'Sep 29, 2026 • 7:50 PM',
    ),
    RaceHistoryData(
      raceNumber: 6,
      winner: 'Northern Flame',
      rankings: ['Northern Flame', 'Golden Arrow', 'Blue Horizon'],
      totalBet: 1940,
      racedAt: 'Sep 28, 2026 • 6:22 PM',
    ),
    RaceHistoryData(
      raceNumber: 3,
      winner: 'Crimson Tide',
      rankings: ['Crimson Tide', 'Emerald Dash', 'Royal Orbit'],
      totalBet: 3215,
      racedAt: 'Sep 27, 2026 • 4:38 PM',
    ),
    RaceHistoryData(
      raceNumber: 12,
      winner: 'Rapid Echo',
      rankings: ['Rapid Echo', 'Silver Tempest', 'Midnight Comet'],
      totalBet: 4120,
      racedAt: 'Sep 26, 2026 • 9:10 PM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bets = betHistory ?? _mockBets;
    final races = raceHistory ?? _mockRaces;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.receipt_long_outlined),
                text: 'My Bets',
              ),
              Tab(
                icon: Icon(Icons.flag_outlined),
                text: 'Race History',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BetHistoryList(bets: bets),
            _RaceHistoryList(races: races),
          ],
        ),
      ),
    );
  }
}

class _BetHistoryList extends StatelessWidget {
  const _BetHistoryList({required this.bets});

  final List<BetHistoryData> bets;

  @override
  Widget build(BuildContext context) {
    if (bets.isEmpty) {
      return const _HistoryEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No bets yet',
        message: 'Your placed bets will appear here.',
      );
    }

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 752
              ? (constraints.maxWidth - 720) / 2
              : 16.0;

          return ListView.separated(
            key: const PageStorageKey('bet-history-list'),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            itemCount: bets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => BetHistoryCard(bet: bets[index]),
          );
        },
      ),
    );
  }
}

class _RaceHistoryList extends StatelessWidget {
  const _RaceHistoryList({required this.races});

  final List<RaceHistoryData> races;

  @override
  Widget build(BuildContext context) {
    if (races.isEmpty) {
      return const _HistoryEmptyState(
        icon: Icons.flag_outlined,
        title: 'No races yet',
        message: 'Completed race results will appear here.',
      );
    }

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 752
              ? (constraints.maxWidth - 720) / 2
              : 16.0;

          return ListView.separated(
            key: const PageStorageKey('race-history-list'),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            itemCount: races.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                RaceHistoryCard(race: races[index]),
          );
        },
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 58,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
