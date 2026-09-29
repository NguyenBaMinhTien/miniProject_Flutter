import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../models/bet_model.dart';
import '../../models/race_state_model.dart';
import '../socket/socket_event.dart';
import '../socket/socket_service.dart';

class GameProvider extends ChangeNotifier {
  GameProvider({required SocketService socketService})
      : _socketService = socketService {
    _subscription = _socketService.events.listen(_handleEvent);
  }

  final SocketService _socketService;
  late final StreamSubscription<SocketEvent> _subscription;

  RaceStateModel? _raceState;
  RacePhase _phase = RacePhase.waiting;
  int _countdown = 0;
  Map<String, double> _positions = const {};
  final List<BetModel> _myBetsThisRound = [];
  BetModel? _lastBetResult;
  String? _error;

  RaceStateModel? get raceState => _raceState;
  RacePhase get phase => _phase;
  int get countdown => _countdown;
  Map<String, double> get positions => UnmodifiableMapView(_positions);
  List<BetModel> get myBetsThisRound => UnmodifiableListView(_myBetsThisRound);
  BetModel? get lastBetResult => _lastBetResult;
  String? get error => _error;

  void placeBet({
    required String raceId,
    required String horseId,
    required double amount,
  }) {
    _socketService.placeBet(
      raceId: raceId,
      horseId: horseId,
      amount: amount,
    );
  }

  void clearLastBetResult() {
    if (_lastBetResult == null) return;
    _lastBetResult = null;
    notifyListeners();
  }

  void _handleEvent(SocketEvent event) {
    try {
      switch (event.type) {
        case SocketEventType.raceState:
          _applyRaceState(event.data);
        case SocketEventType.countdown:
          _applyCountdown(event.data);
        case SocketEventType.raceTick:
          _applyRaceTick(event.data);
        case SocketEventType.raceFinished:
          _applyRaceFinished(event.data);
        case SocketEventType.betConfirmed:
          _upsertBet(_parseBet(event.data));
        case SocketEventType.betResult:
          final result = _parseBet(event.data);
          _upsertBet(result);
          _lastBetResult = result;
        case SocketEventType.raceCancelled:
          _phase = RacePhase.cancelled;
          _raceState = _raceState?.copyWith(phase: RacePhase.cancelled);
        case SocketEventType.betRefunded:
          final refund = _parseBet(event.data);
          _upsertBet(refund);
          _lastBetResult = refund;
        case SocketEventType.error:
          _error = event.data['message']?.toString() ?? 'Game socket error';
        case SocketEventType.welcome:
        case SocketEventType.authSuccess:
        case SocketEventType.balanceUpdate:
        case SocketEventType.pong:
          return;
      }
      notifyListeners();
    } catch (error) {
      _error = 'Invalid ${event.type.name.toUpperCase()} payload: $error';
      notifyListeners();
    }
  }

  void _applyRaceState(Map<String, dynamic> data) {
    final state = RaceStateModel.fromJson(data);
    if (_raceState?.raceId != state.raceId) {
      _myBetsThisRound.clear();
      _lastBetResult = null;
    }
    _raceState = state;
    _phase = state.phase;
    _countdown = state.countdown;
    _positions = Map<String, double>.from(state.positions);
    _error = null;
  }

  void _applyCountdown(Map<String, dynamic> data) {
    final value = data['countdown'];
    if (value is! num) throw const FormatException('countdown must be numeric');
    _countdown = value.toInt();
    _raceState = _raceState?.copyWith(countdown: _countdown);
  }

  void _applyRaceTick(Map<String, dynamic> data) {
    final rawPositions = data['positions'];
    if (rawPositions is! Map) {
      throw const FormatException('positions must be an object');
    }
    _positions = rawPositions.map<String, double>(
      (key, value) {
        if (value is! num) {
          throw const FormatException('position must be numeric');
        }
        return MapEntry(key.toString(), value.toDouble());
      },
    );
    _raceState = _raceState?.copyWith(positions: _positions);
  }

  void _applyRaceFinished(Map<String, dynamic> data) {
    _phase = RacePhase.finished;
    if (data['positions'] != null) _applyRaceTick(data);
    _raceState = _raceState?.copyWith(
      phase: RacePhase.finished,
      winnerId: data['winnerId']?.toString(),
    );
  }

  BetModel _parseBet(Map<String, dynamic> data) {
    final dynamic rawBet = data['bet'] ?? data;
    if (rawBet is! Map) throw const FormatException('bet must be an object');
    return BetModel.fromJson(
      rawBet.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );
  }

  void _upsertBet(BetModel bet) {
    final index = _myBetsThisRound.indexWhere((item) => item.id == bet.id);
    if (index == -1) {
      _myBetsThisRound.add(bet);
    } else {
      _myBetsThisRound[index] = bet;
    }
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
