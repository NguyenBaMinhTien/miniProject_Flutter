// DEV 3 Scope: Game state contract consumed by GameScreen
import 'package:flutter/foundation.dart';

import '../../../models/horse.dart';
import '../widgets/track/models/race_phase.dart';
import 'bet_models.dart';

/// Sự kiện một lần (hiện popup/snackbar), tách khỏi state để không lặp lại
/// mỗi lần rebuild.
sealed class GameEvent {
  const GameEvent();
}

class BetConfirmedEvent extends GameEvent {
  final BetTicket ticket;
  const BetConfirmedEvent(this.ticket);
}

class BetErrorEvent extends GameEvent {
  final String message;
  const BetErrorEvent(this.message);
}

class BetResultEvent extends GameEvent {
  final RoundResult result;
  const BetResultEvent(this.result);
}

class RaceCancelledEvent extends GameEvent {
  final int refundedAmount;
  const RaceCancelledEvent(this.refundedAmount);
}

/// Tên state bám theo GameProvider (MBE-08) của DEV 1 để sau này thay
/// MockGameController bằng bản dùng GameProvider + SocketService mà UI giữ nguyên.
/// Số dư không nằm ở đây mà đọc từ WalletProvider (xem wallet_cash_source.dart).
abstract class GameController extends ChangeNotifier {
  List<Horse> get horses;
  RacePhase get phase;
  int get countdown;
  List<double> get positions;
  String? get winnerHorseId;
  List<BetTicket> get myBetsThisRound;
  RoundResult? get lastBetResult;
  bool get isPlacingBet;

  Stream<GameEvent> get events;

  Future<void> start();

  /// Gửi PLACE_BET. Kết quả trả về qua [events] (BetConfirmedEvent / BetErrorEvent).
  Future<void> placeBet({required String horseId, required int amount});
}
