// DEV 3 Scope: Mock game loop dùng cho tới khi backend của DEV 1 xong
import 'dart:async';
import 'dart:math';

import '../../../models/horse.dart';
import '../widgets/track/models/race_phase.dart';
import 'bet_models.dart';
import 'game_controller.dart';
import 'horse_repository.dart';
import 'wallet_cash_source.dart';

/// Giả lập server: BETTING → RACING → FINISHED → BETTING (và CANCELLED).
/// Winner, settlement và validate cược đều nằm ở đây giống như backend,
/// UI không tự tính. Số dư nằm ở [wallet], được cập nhật như BALANCE_UPDATE.
class MockGameController extends GameController {
  MockGameController({
    required this.wallet,
    HorseRepository? repository,
    this.minBet = 100,
    this.maxBet = 10000,
    this.bettingSeconds = 15,
    this.finishedSeconds = 8,
    this.cancelledSeconds = 5,
    this.secondDuration = const Duration(seconds: 1),
    this.tickDuration = const Duration(milliseconds: 100),
    this.networkDelay = const Duration(milliseconds: 200),
    Random? random,
  }) : _repository = repository ?? horseRepository,
       _random = random ?? Random();

  final HorseRepository _repository;
  final Random _random;

  final MockWalletProvider wallet;
  final int minBet;
  final int maxBet;
  final int bettingSeconds;
  final int finishedSeconds;
  final int cancelledSeconds;
  final Duration secondDuration;
  final Duration tickDuration;
  final Duration networkDelay;

  final StreamController<GameEvent> _events =
      StreamController<GameEvent>.broadcast();

  Timer? _timer;
  bool _disposed = false;
  int _raceNumber = 0;
  int _betSeq = 0;

  List<Horse> _horses = const [];
  RacePhase _phase = RacePhase.betting;
  int _countdown = 0;
  List<double> _positions = const [];
  List<double> _speeds = const [];
  String? _winnerHorseId;
  List<BetTicket> _myBets = const [];
  RoundResult? _lastBetResult;
  bool _isPlacingBet = false;

  @override
  List<Horse> get horses => _horses;
  @override
  RacePhase get phase => _phase;
  @override
  int get countdown => _countdown;
  @override
  List<double> get positions => _positions;
  @override
  String? get winnerHorseId => _winnerHorseId;
  @override
  List<BetTicket> get myBetsThisRound => _myBets;
  @override
  RoundResult? get lastBetResult => _lastBetResult;
  @override
  bool get isPlacingBet => _isPlacingBet;
  @override
  Stream<GameEvent> get events => _events.stream;

  String get _raceId => 'race_$_raceNumber';

  @override
  Future<void> start() async {
    _horses = await _repository.getHorses();
    if (_disposed) return;
    _enterBetting();
  }

  @override
  Future<void> placeBet({required String horseId, required int amount}) async {
    if (_isPlacingBet) return;
    _isPlacingBet = true;
    _notify();

    await Future.delayed(networkDelay);
    if (_disposed) return;
    _isPlacingBet = false;

    final error = _validateBet(horseId, amount);
    if (error != null) {
      _emit(BetErrorEvent(error));
      _notify();
      return;
    }

    final horse = _horses.firstWhere((h) => h.id == horseId);
    final ticket = BetTicket(
      id: 'bet_${++_betSeq}',
      raceId: _raceId,
      horseId: horse.id,
      horseName: horse.name,
      odds: horse.odds,
      amount: amount,
      potentialPayout: (amount * horse.odds).round(),
    );
    wallet.applyBalanceUpdate(wallet.cash - amount);
    _myBets = [..._myBets, ticket];
    _emit(BetConfirmedEvent(ticket));
    _notify();
  }

  /// Chỉ dùng để test luồng CANCELLED khi chưa có backend.
  void debugCancelRace() {
    if (_phase != RacePhase.betting) return;
    _enterCancelled();
  }

  String? _validateBet(String horseId, int amount) {
    if (_phase != RacePhase.betting) return 'Đã hết thời gian đặt cược.';
    if (!_horses.any((h) => h.id == horseId)) return 'Ngựa không tồn tại.';
    if (amount < minBet || amount > maxBet) {
      return 'Số tiền cược phải từ $minBet đến $maxBet.';
    }
    if (amount > wallet.cash) return 'Số dư không đủ.';
    return null;
  }

  void _enterBetting() {
    _raceNumber++;
    _phase = RacePhase.betting;
    _positions = List<double>.filled(_horses.length, 0);
    _winnerHorseId = null;
    _myBets = const [];
    _startCountdown(bettingSeconds, _enterRacing);
  }

  void _enterRacing() {
    _phase = RacePhase.racing;
    _countdown = 0;
    // Mỗi ngựa có phong độ riêng trong vòng này để cuộc đua giãn ra.
    _speeds = [for (final _ in _horses) 0.75 + _random.nextDouble() * 0.5];
    _notify();
    _timer?.cancel();
    _timer = Timer.periodic(tickDuration, (_) => _raceTick());
  }

  void _raceTick() {
    // Trung bình ~0.8/tick → khoảng 12s với tick 100ms.
    _positions = [
      for (var i = 0; i < _positions.length; i++)
        min(100.0, _positions[i] + _speeds[i] * (0.4 + _random.nextDouble() * 0.8)),
    ];
    final leader = _leaderIndex();
    if (_positions[leader] >= 100) {
      _winnerHorseId = _horses[leader].id;
      _enterFinished();
    } else {
      _notify();
    }
  }

  int _leaderIndex() {
    var leader = 0;
    for (var i = 1; i < _positions.length; i++) {
      if (_positions[i] > _positions[leader]) leader = i;
    }
    return leader;
  }

  void _enterFinished() {
    _phase = RacePhase.finished;
    final winner = _winnerHorseId!;
    final results = [
      for (final t in _myBets)
        t.horseId == winner
            ? BetResult(ticket: t, outcome: BetOutcome.won, payout: t.potentialPayout)
            : BetResult(ticket: t, outcome: BetOutcome.lost, payout: 0),
    ];
    final result = RoundResult(raceId: _raceId, winnerHorseId: winner, results: results);
    wallet.applyBalanceUpdate(wallet.cash + result.totalPayout);
    _lastBetResult = result;
    _emit(BetResultEvent(result));
    _startCountdown(finishedSeconds, _enterBetting);
  }

  void _enterCancelled() {
    _phase = RacePhase.cancelled;
    final refund = _myBets.fold(0, (sum, t) => sum + t.amount);
    wallet.applyBalanceUpdate(wallet.cash + refund);
    _myBets = const [];
    _emit(RaceCancelledEvent(refund));
    _startCountdown(cancelledSeconds, _enterBetting);
  }

  void _startCountdown(int seconds, void Function() onDone) {
    _timer?.cancel();
    _countdown = seconds;
    _notify();
    _timer = Timer.periodic(secondDuration, (timer) {
      _countdown--;
      if (_countdown <= 0) {
        timer.cancel();
        onDone();
      } else {
        _notify();
      }
    });
  }

  void _emit(GameEvent event) {
    if (!_disposed) _events.add(event);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _events.close();
    super.dispose();
  }
}
