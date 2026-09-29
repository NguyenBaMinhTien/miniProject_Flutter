import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_horse_racing/models/bet.dart' as legacy_bet;
import 'package:flutter_horse_racing/models/bet_model.dart';
import 'package:flutter_horse_racing/models/horse.dart' as legacy_horse;
import 'package:flutter_horse_racing/models/horse_model.dart';
import 'package:flutter_horse_racing/models/payment_order_model.dart';
import 'package:flutter_horse_racing/models/race.dart' as legacy_race;
import 'package:flutter_horse_racing/models/race_state_model.dart';
import 'package:flutter_horse_racing/models/transaction_model.dart';
import 'package:flutter_horse_racing/models/user.dart' as legacy_user;
import 'package:flutter_horse_racing/models/user_model.dart';
import 'package:flutter_horse_racing/models/winner_model.dart';

void main() {
  test('models parse int and double numeric values', () {
    final user = UserModel.fromJson({
      'id': 'user_1',
      'username': 'rider',
      'fullName': 'Race Rider',
      'cash': 50000,
    });
    final horse = HorseModel.fromJson({
      'id': 'horse_2',
      'name': 'Bach Long',
      'color': 'blue',
      'odds': 3,
      'lane': 2,
    });
    final bet = BetModel.fromJson({
      'id': 'bet_1',
      'raceId': 'race_1',
      'horseId': 'horse_2',
      'horseName': 'Bach Long',
      'odds': 3,
      'amount': 2000,
      'potentialPayout': 6000.0,
      'payout': 0,
      'status': 'PENDING',
      'placedAt': '2026-09-29T10:00:00.000Z',
    });

    expect(user.cash, 50000.0);
    expect(horse.odds, 3.0);
    expect(bet.amount, 2000.0);
    expect(bet.potentialPayout, 6000.0);
  });

  test('models round trip contract JSON', () {
    final raceJson = <String, dynamic>{
      'raceId': 'race_1',
      'raceNumber': 12,
      'phase': 'RACING',
      'countdown': 0,
      'horses': [
        {
          'id': 'horse_1',
          'name': 'Xich Tho',
          'color': 'red',
          'odds': 2.5,
          'lane': 1,
        },
      ],
      'positions': {'horse_1': 42.5},
      'winnerId': null,
    };
    final transactionJson = <String, dynamic>{
      'id': 'tx_1',
      'type': 'DEPOSIT',
      'amount': 50000,
      'balanceAfter': 100000,
      'description': 'Mock deposit',
      'createdAt': '2026-09-29T10:01:00.000Z',
    };
    final paymentJson = <String, dynamic>{
      'id': 'payment_1',
      'amount': 50000,
      'status': 'COMPLETED',
      'qrCode': 'MOCK-QR',
      'createdAt': '2026-09-29T10:02:00.000Z',
    };
    final winnerJson = <String, dynamic>{
      'raceId': 'race_1',
      'raceNumber': 12,
      'horseId': 'horse_1',
      'horseName': 'Xich Tho',
      'rankings': ['horse_1', 'horse_2'],
      'finishedAt': '2026-09-29T10:03:00.000Z',
    };

    final race = RaceStateModel.fromJson(raceJson);
    final transaction = TransactionModel.fromJson(transactionJson);
    final payment = PaymentOrderModel.fromJson(paymentJson);
    final winner = WinnerModel.fromJson(winnerJson);

    expect(race.raceId, 'race_1');
    expect(race.phase, RacePhase.racing);
    expect(race.positions, {'horse_1': 42.5});
    expect(race.toJson(), raceJson);
    expect(transaction.type, TransactionType.deposit);
    expect(transaction.toJson(), transactionJson);
    expect(payment.toJson(), paymentJson);
    expect(winner.rankings, ['horse_1', 'horse_2']);
    expect(winner.toJson(), winnerJson);
  });

  test('unknown enum values use safe fallbacks', () {
    final race = RaceStateModel.fromJson({
      'raceId': 'race_unknown',
      'raceNumber': 1,
      'phase': 'SOMETHING_NEW',
      'countdown': 0,
      'horses': const [],
      'positions': const {},
    });
    final bet = BetModel.fromJson({
      'id': 'bet_unknown',
      'raceId': 'race_unknown',
      'horseId': 'horse_unknown',
      'horseName': 'Unknown',
      'odds': 1,
      'amount': 100,
      'potentialPayout': 100,
      'payout': 0,
      'status': 'SOMETHING_NEW',
      'placedAt': '2026-09-29T10:00:00.000Z',
    });
    final transaction = TransactionModel.fromJson({
      'id': 'tx_unknown',
      'type': 'SOMETHING_NEW',
      'amount': 100,
      'balanceAfter': 100,
      'createdAt': '2026-09-29T10:00:00.000Z',
    });

    expect(race.phase, RacePhase.waiting);
    expect(bet.status, BetStatus.pending);
    expect(transaction.type, TransactionType.unknown);
  });

  test('legacy model imports remain constructible', () {
    const user = legacy_user.User(
      id: 'legacy_user',
      username: 'legacy',
      balance: 10,
    );
    const horse = legacy_horse.Horse(
      id: 'legacy_horse',
      name: 'Legacy Horse',
      color: 'red',
    );
    const race = legacy_race.Race(
      id: 'legacy_race',
      horses: [horse],
      status: 'BETTING',
    );
    const bet = legacy_bet.Bet(
      id: 'legacy_bet',
      horseId: 'legacy_horse',
      amount: 100,
    );

    expect(user.balance, 10);
    expect(race.status, 'BETTING');
    expect(bet.amount, 100);
  });
}
