import '../models/celebration.dart';
import '../models/child_companion_profile.dart';
import '../models/companion_memory.dart';
import '../models/companion_context.dart';
import '../models/companion_observation.dart';
import '../models/companion_suggestion_result.dart';
import '../services/companion_brain_service.dart';
import '../services/companion_service.dart';
import '../services/companion_observation_recorder.dart';

class CompanionRepository {
  CompanionRepository({
    CompanionService? service,
    CompanionBrainService? brainService,
    CompanionObservationRecorder? observationRecorder,
  }) : _service = service ?? CompanionService(),
       _brainService = brainService ?? const CompanionBrainService(),
       _observationRecorder =
           observationRecorder ?? const CompanionObservationRecorder();

  final CompanionService _service;
  final CompanionBrainService _brainService;
  final CompanionObservationRecorder _observationRecorder;

  CompanionSuggestionResult selectIdeas(CompanionContext context) =>
      _brainService.selectIdeas(context);

  Future<void> saveProfile({
    required String familyId,
    required String childId,
    required ChildCompanionProfile profile,
  }) => _service.saveProfile(
    familyId: familyId,
    childId: childId,
    profile: profile,
  );

  String generateMemoryId(String familyId, String childId) =>
      _service.generateMemoryId(familyId, childId);

  Future<void> saveMemory({
    required String familyId,
    required CompanionMemory memory,
  }) => _service.saveMemory(familyId: familyId, memory: memory);

  Future<List<CompanionMemory>> getMemories({
    required String familyId,
    required String childId,
  }) => _service.getMemories(familyId: familyId, childId: childId);

  String generateCelebrationId(String familyId, String childId) =>
      _service.generateCelebrationId(familyId, childId);

  Future<void> saveCelebration({
    required String familyId,
    required Celebration celebration,
  }) => _service.saveCelebration(familyId: familyId, celebration: celebration);

  Future<List<Celebration>> getCelebrations({
    required String familyId,
    required String childId,
  }) => _service.getCelebrations(familyId: familyId, childId: childId);

  String generateObservationId(String familyId, String childId) =>
      _service.generateObservationId(familyId, childId);

  Future<void> saveObservation({
    required String familyId,
    required CompanionObservation observation,
  }) => _observationRecorder.record(
    observation: observation,
    persist: (value) =>
        _service.saveObservation(familyId: familyId, observation: value),
  );

  Future<List<CompanionObservation>> getRecentObservations({
    required String familyId,
    required String childId,
    int limit = 30,
  }) => _service.getRecentObservations(
    familyId: familyId,
    childId: childId,
    limit: limit,
  );
}
