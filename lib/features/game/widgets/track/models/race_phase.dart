enum RacePhase { betting, racing, finished, cancelled }

extension RacePhaseX on RacePhase {
  bool get isRacing => this == RacePhase.racing;
  bool get isFinished => this == RacePhase.finished;
}
