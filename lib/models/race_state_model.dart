import 'package:flutter/foundation.dart';

import 'horse_model.dart';

enum RacePhase { waiting, betting, racing, finished, cancelled }

RacePhase racePhaseFromJson(Object? value) {
  return RacePhase.values.firstWhere(
    (phase) => phase.name.toUpperCase() == value?.toString().toUpperCase(),
    orElse: () => RacePhase.waiting,
  );
}

class RaceStateModel {
  const RaceStateModel({
    required this.raceId,
    required this.raceNumber,
    required this.phase,
    required this.countdown,
    required this.horses,
    required this.positions,
    this.winnerId,
  });

  factory RaceStateModel.fromJson(Map<String, dynamic> json) {
    final horsesJson = json['horses'] as List<dynamic>? ?? const [];
    final positionsJson =
        json['positions'] as Map<dynamic, dynamic>? ?? const {};
    return RaceStateModel(
      raceId: json['raceId'] as String,
      raceNumber: (json['raceNumber'] as num).toInt(),
      phase: racePhaseFromJson(json['phase']),
      countdown: (json['countdown'] as num).toInt(),
      horses: horsesJson
          .map((item) => HorseModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      positions: positionsJson.map(
        (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
      ),
      winnerId: json['winnerId'] as String?,
    );
  }

  final String raceId;
  final int raceNumber;
  final RacePhase phase;
  final int countdown;
  final List<HorseModel> horses;
  final Map<String, double> positions;
  final String? winnerId;

  Map<String, dynamic> toJson() => {
        'raceId': raceId,
        'raceNumber': raceNumber,
        'phase': phase.name.toUpperCase(),
        'countdown': countdown,
        'horses': horses.map((horse) => horse.toJson()).toList(),
        'positions': positions,
        'winnerId': winnerId,
      };

  RaceStateModel copyWith({
    String? raceId,
    int? raceNumber,
    RacePhase? phase,
    int? countdown,
    List<HorseModel>? horses,
    Map<String, double>? positions,
    String? winnerId,
    bool clearWinner = false,
  }) {
    return RaceStateModel(
      raceId: raceId ?? this.raceId,
      raceNumber: raceNumber ?? this.raceNumber,
      phase: phase ?? this.phase,
      countdown: countdown ?? this.countdown,
      horses: horses ?? this.horses,
      positions: positions ?? this.positions,
      winnerId: clearWinner ? null : winnerId ?? this.winnerId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RaceStateModel &&
          raceId == other.raceId &&
          raceNumber == other.raceNumber &&
          phase == other.phase &&
          countdown == other.countdown &&
          listEquals(horses, other.horses) &&
          mapEquals(positions, other.positions) &&
          winnerId == other.winnerId;

  @override
  int get hashCode => Object.hash(
        raceId,
        raceNumber,
        phase,
        countdown,
        Object.hashAll(horses),
        Object.hashAllUnordered(positions.entries),
        winnerId,
      );
}
