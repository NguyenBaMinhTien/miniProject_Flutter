// DEV 5 Scope: Auth UI, History, Profile, Audio & App Shell
import 'package:flutter/material.dart';

class HorseRacingApp extends StatelessWidget {
  const HorseRacingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horse Racing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Flutter Horse Racing App Initialized'),
        ),
      ),
    );
  }
}
