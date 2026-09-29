// DEV 3 Scope: Entry point chạy thẳng vào GameScreen khi phát triển,
// không phụ thuộc app.dart / MainAppShell của DEV 5.
// Chạy: flutter run -t lib/main_game_dev.dart
import 'package:flutter/material.dart';

import 'features/game/screens/game_screen.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Horse Racing - Game (dev)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    ),
  );
}
