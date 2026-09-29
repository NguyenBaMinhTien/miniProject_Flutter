import 'package:flutter_horse_racing/core/storage/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorage(await SharedPreferences.getInstance());
  });

  test('token and username round trip', () async {
    await storage.saveToken('jwt-token');
    await storage.saveUsername('demo');

    expect(storage.getToken(), 'jwt-token');
    expect(storage.getUsername(), 'demo');
  });

  test('mute defaults to false and persists changes', () async {
    expect(storage.isMuted(), isFalse);

    await storage.setMuted(true);

    expect(storage.isMuted(), isTrue);
  });

  test('clearAuth removes identity but preserves mute preference', () async {
    await storage.saveToken('jwt-token');
    await storage.saveUsername('demo');
    await storage.setMuted(true);

    await storage.clearAuth();

    expect(storage.getToken(), isNull);
    expect(storage.getUsername(), isNull);
    expect(storage.isMuted(), isTrue);
  });
}
