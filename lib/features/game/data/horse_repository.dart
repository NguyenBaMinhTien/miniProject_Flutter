// DEV 3 Scope: Horse data source for Betting & Game Loop UI
import '../../../models/horse.dart';

abstract class HorseRepository {
  Future<List<Horse>> getHorses();
}

/// Mock theo BE-05 Horse Configuration, dùng cho tới khi API của DEV 1 xong.
class MockHorseRepository implements HorseRepository {
  static const List<Map<String, dynamic>> _mockResponse = [
    {'id': 1, 'number': 1, 'name': 'Xích Thố', 'odds': 2.2, 'color': 'red'},
    {'id': 2, 'number': 2, 'name': 'Bạch Long', 'odds': 3.0, 'color': 'blue'},
    {'id': 3, 'number': 3, 'name': 'Kim Quy', 'odds': 4.0, 'color': 'gold'},
    {'id': 4, 'number': 4, 'name': 'Hắc Báo', 'odds': 5.5, 'color': 'purple'},
    {'id': 5, 'number': 5, 'name': 'Thanh Long', 'odds': 7.0, 'color': 'green'},
  ];

  @override
  Future<List<Horse>> getHorses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockResponse.map(Horse.fromJson).toList();
  }
}

// TODO(DEV 3): Khi DEV 1 xong Horse Configuration API, thêm ApiHorseRepository
// gọi endpoint qua ApiClient/ApiEndpoints của DEV 1 và parse bằng Horse.fromJson,
// rồi đổi dòng bên dưới sang ApiHorseRepository(). UI không cần sửa.
final HorseRepository horseRepository = MockHorseRepository();
