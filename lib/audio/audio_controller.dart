// DEV 5 Scope: Audio Controller
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

// TODO(TEAM-INTEGRATION): Bind these methods only after Game exposes a public
// event source. Expected mapping:
// countdown <= 3 -> playCountdownBeep
// betting -> racing -> playRaceStart, startGalloping
// racing -> finished -> stopGalloping, playCrowdCheer
// bet won/lost -> playWinFanfare/playLoseBuzzer
class AudioController extends ChangeNotifier {
  AudioController()
      : _effectsPlayer = AudioPlayer(),
        _gallopingPlayer = AudioPlayer();

  static const _audioPath = 'audio/';

  final AudioPlayer _effectsPlayer;
  final AudioPlayer _gallopingPlayer;

  bool _isSoundEnabled = true;
  bool _isGalloping = false;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isGalloping => _isGalloping;

  Future<void> setSoundEnabled(bool enabled) async {
    if (_isSoundEnabled == enabled) return;

    _isSoundEnabled = enabled;
    if (!enabled) {
      _isGalloping = false;
    }
    notifyListeners();

    if (!enabled) {
      await Future.wait([
        _effectsPlayer.stop(),
        _gallopingPlayer.stop(),
      ]);
    }
  }

  Future<void> playCountdownBeep() => _playEffect('countdown_beep.mp3');

  Future<void> playRaceStart() => _playEffect('race_start_horn.mp3');

  Future<void> playCrowdCheer() => _playEffect('crowd_cheer.mp3');

  Future<void> playWinFanfare() => _playEffect('win_fanfare.mp3');

  Future<void> playLoseBuzzer() => _playEffect('lose_buzzer.mp3');

  Future<void> playChipPlace() => _playEffect('chip_place.mp3');

  Future<void> playCashRegister() => _playEffect('cash_register.mp3');

  Future<void> playButtonTap() => _playEffect('button_tap.mp3');

  Future<void> startGalloping() async {
    if (!_isSoundEnabled || _isGalloping) return;

    await _gallopingPlayer.setReleaseMode(ReleaseMode.loop);
    await _gallopingPlayer.play(
      AssetSource('${_audioPath}galloping_loop.mp3'),
    );
    _isGalloping = true;
    notifyListeners();
  }

  Future<void> stopGalloping() async {
    await _gallopingPlayer.stop();
    if (!_isGalloping) return;

    _isGalloping = false;
    notifyListeners();
  }

  Future<void> _playEffect(String fileName) async {
    if (!_isSoundEnabled) return;
    await _effectsPlayer.play(AssetSource('$_audioPath$fileName'));
  }

  @override
  void dispose() {
    unawaited(_effectsPlayer.dispose());
    unawaited(_gallopingPlayer.dispose());
    super.dispose();
  }
}
