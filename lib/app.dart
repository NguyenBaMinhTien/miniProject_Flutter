// DEV 5 Scope: Auth UI, History, Profile, Audio & App Shell
import 'package:flutter/material.dart';

import 'features/auth/screens/splash_screen.dart';
import 'features/game/screens/game_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/wallet/screens/wallet_screen.dart';

class HorseRacingApp extends StatelessWidget {
  const HorseRacingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horse Racing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB77700),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/main': (_) => const MainAppShell(),
      },
    );
  }
}

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  static const _screens = <Widget>[
    GameScreen(),
    WalletScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == _selectedIndex) return;
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_score_outlined),
            activeIcon: Icon(Icons.sports_score_rounded),
            label: 'Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
