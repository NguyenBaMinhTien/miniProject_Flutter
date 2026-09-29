import 'package:flutter/material.dart';

/// Shared visual and motion tokens for the race-track feature.
///
/// Keeping these values in one place makes the whole track consistent and
/// allows the UI to be reskinned without changing its animation logic.
abstract final class RaceTrackSystem {
  static const double laneHeight = 68;
  static const double horseWidth = 58;
  static const double finishLineWidth = 18;
  static const double horizontalPadding = 12;

  static const Duration raceTickDuration = Duration(milliseconds: 120);
  static const Duration idleMoveDuration = Duration(milliseconds: 250);
  static const Duration winnerDuration = Duration(seconds: 3);

  static const Color grass = Color(0xFF2F7D32);
  static const Color grassDark = Color(0xFF256428);
  static const Color laneLine = Color(0xB3FFFFFF);
  static const Color dirt = Color(0xFFB9834D);
  static const Color panel = Color(0xFF17351F);

  static const List<Color> horseColors = <Color>[
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFFFFB300),
    Color(0xFF8E24AA),
    Color(0xFF43A047),
  ];

  static Color parseHorseColor(String value, {int fallbackIndex = 0}) {
    final normalized = value.trim().toLowerCase();
    const namedColors = <String, Color>{
      'red': Color(0xFFE53935),
      'blue': Color(0xFF1E88E5),
      'gold': Color(0xFFFFB300),
      'yellow': Color(0xFFFFB300),
      'purple': Color(0xFF8E24AA),
      'green': Color(0xFF43A047),
    };
    final named = namedColors[normalized];
    if (named != null) return named;

    final hex = normalized.replaceFirst('#', '');
    if (hex.length == 6 || hex.length == 8) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) {
        return Color(hex.length == 6 ? 0xFF000000 | parsed : parsed);
      }
    }
    return horseColors[fallbackIndex % horseColors.length];
  }
}
