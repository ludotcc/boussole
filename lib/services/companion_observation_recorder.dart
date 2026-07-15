import '../models/companion_observation.dart';

typedef CompanionObservationPersistence =
    Future<void> Function(CompanionObservation observation);

class CompanionObservationRecorder {
  const CompanionObservationRecorder();

  Future<void> record({
    required CompanionObservation observation,
    required CompanionObservationPersistence persist,
  }) => persist(observation);
}
