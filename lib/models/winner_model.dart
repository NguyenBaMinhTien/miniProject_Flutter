import 'package:flutter/foundation.dart';

class WinnerModel {
  const WinnerModel({
    required this.raceId,
    required this.raceNumber,
    required this.horseId,
    required this.horseName,
    required this.rankings,
    required this.finishedAt,
  });

  factory WinnerModel.fromJson(Map<String, dynamic> json) {
    return WinnerModel(
      raceId: json['raceId'] as String,
      raceNumber: (json['raceNumber'] as num).toInt(),
      horseId: json['horseId'].toString(),
      horseName: json['horseName'] as String,
      rankings: (json['rankings'] as List<dynamic>)
          .map((value) => value.toString())
          .toList(growable: false),
      finishedAt: DateTime.parse(json['finishedAt'] as String),
    );
  }

  final String raceId;
  final int raceNumber;
  final String horseId;
  final String horseName;
  final List<String> rankings;
  final DateTime finishedAt;

  Map<String, dynamic> toJson() => {
        'raceId': raceId,
        'raceNumber': raceNumber,
        'horseId': horseId,
        'horseName': horseName,
        'rankings': rankings,
        'finishedAt': finishedAt.toUtc().toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WinnerModel &&
          raceId == other.raceId &&
          raceNumber == other.raceNumber &&
          horseId == other.horseId &&
          horseName == other.horseName &&
          listEquals(rankings, other.rankings) &&
          finishedAt == other.finishedAt;

  @override
  int get hashCode => Object.hash(
        raceId,
        raceNumber,
        horseId,
        horseName,
        Object.hashAll(rankings),
        finishedAt,
      );
}
