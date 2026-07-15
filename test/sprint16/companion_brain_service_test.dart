import 'package:boussole/models/child_companion_profile.dart';
import 'package:boussole/models/child_model.dart';
import 'package:boussole/models/companion_context.dart';
import 'package:boussole/models/companion_memory.dart';
import 'package:boussole/models/companion_moment.dart';
import 'package:boussole/models/companion_observation.dart';
import 'package:boussole/services/companion_brain_service.dart';
import 'package:boussole/services/companion_observation_recorder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CompanionMoment moment({
    required String id,
    CompanionMomentFamily family = CompanionMomentFamily.play,
    int minimumAge = 3,
    int maximumAge = 12,
    int duration = 10,
    Set<String> contexts = const {'home'},
    Set<String> mainMoments = const {},
    Set<String> avoided = const {},
    Set<String> sensitive = const {},
    Set<String> tags = const {},
  }) => CompanionMoment(
    id: id,
    title: id,
    shortDescription: id,
    primaryNeed: CompanionNeed.findIdea,
    family: family,
    minimumAge: minimumAge,
    maximumAge: maximumAge,
    durationMinutes: duration,
    compatibleContexts: contexts,
    compatibleMainMoments: mainMoments,
    participants: CompanionParticipantContext.alone,
    incompatibleAvoidedActivities: avoided,
    incompatibleSensitiveSituations: sensitive,
    tags: tags,
  );

  ChildModel child({
    int age = 8,
    ChildCompanionProfile profile = const ChildCompanionProfile(),
  }) => ChildModel(
    id: 'child',
    familyId: 'family',
    firstName: 'Lina',
    avatar: 'avatar',
    age: age,
    companionProfile: profile,
    createdAt: DateTime(2026),
  );

  CompanionContext context({
    ChildModel? selectedChild,
    Set<String> contexts = const {'home'},
    String mainMoment = 'freeTime',
    int duration = 30,
    List<CompanionMemory> memories = const [],
  }) => CompanionContext(
    dateTime: DateTime(2026, 7, 15, 15),
    isSchoolDay: false,
    isVacation: true,
    mainMoment: mainMoment,
    availableContexts: contexts,
    availableDurationMinutes: duration,
    primaryNeed: CompanionNeed.findIdea,
    child: selectedChild ?? child(),
    validatedMemories: memories,
  );

  test('filtre selon l age', () {
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'young', maximumAge: 6),
        moment(id: 'valid'),
      ],
    );

    expect(service.selectIdeas(context()).ideas.map((idea) => idea.id), [
      'valid',
    ]);
  });

  test('filtre selon le contexte et le moment principal', () {
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'outside', contexts: {'outside'}),
        moment(id: 'bed', mainMoments: {'beforeBed'}),
        moment(id: 'valid', mainMoments: {'freeTime'}),
      ],
    );

    expect(service.selectIdeas(context()).ideas.map((idea) => idea.id), [
      'valid',
    ]);
  });

  test('filtre selon la duree disponible', () {
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'long', duration: 20),
        moment(id: 'short', duration: 5),
      ],
    );

    expect(service.selectIdeas(context(duration: 10)).ideas.single.id, 'short');
  });

  test('respecte une activite a eviter', () {
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'drawing', avoided: {'dessin'}),
        moment(id: 'valid'),
      ],
    );
    final selectedChild = child(
      profile: const ChildCompanionProfile(activitiesToAvoid: ['dessin']),
    );

    expect(
      service
          .selectIdeas(context(selectedChild: selectedChild))
          .ideas
          .map((idea) => idea.id),
      ['valid'],
    );
  });

  test('respecte une situation sensible', () {
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'noisy', sensitive: {'bruit important'}),
        moment(id: 'valid'),
      ],
    );
    final selectedChild = child(
      profile: const ChildCompanionProfile(
        specialNeeds: ['hypersensibilité'],
        sensitiveSituations: ['bruit important'],
      ),
    );

    expect(
      service
          .selectIdeas(context(selectedChild: selectedChild))
          .ideas
          .map((idea) => idea.id),
      ['valid'],
    );
  });

  test('une memoire validee influence la priorite', () {
    final now = DateTime(2026, 7, 15);
    final memory = CompanionMemory(
      id: 'memory',
      childId: 'child',
      type: CompanionMemoryType.likedActivity,
      value: 'aime construire',
      status: CompanionMemoryStatus.validated,
      priority: 2,
      reliability: 0.8,
      observationCount: 5,
      createdAt: now,
      updatedAt: now,
      lastObservedAt: now,
    );
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'other', family: CompanionMomentFamily.observe),
        moment(
          id: 'build',
          family: CompanionMomentFamily.build,
          tags: {'construire'},
        ),
      ],
    );

    expect(
      service.selectIdeas(context(memories: [memory])).ideas.first.id,
      'build',
    );
  });

  test('selectionne au maximum trois familles differentes', () {
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'play', family: CompanionMomentFamily.play),
        moment(id: 'read', family: CompanionMomentFamily.read),
        moment(id: 'build', family: CompanionMomentFamily.build),
        moment(id: 'draw', family: CompanionMomentFamily.draw),
      ],
    );

    final ideas = service.selectIdeas(context()).ideas;
    expect(ideas, hasLength(3));
    expect(ideas.map((idea) => idea.family).toSet(), hasLength(3));
  });

  test('n invente aucune idee si moins de trois sont compatibles', () {
    final service = CompanionBrainService(catalog: [moment(id: 'only')]);

    expect(service.selectIdeas(context()).ideas.map((idea) => idea.id), [
      'only',
    ]);
  });

  test('Ma journee reste separee des idees', () {
    final result = CompanionBrainService(
      catalog: [moment(id: 'idea')],
    ).selectIdeas(context());

    expect(result.isMyDayAvailable, isTrue);
    expect(result.ideas.map((idea) => idea.id), isNot(contains('myDay')));
  });

  test('enregistre une observation sans creer de memoire', () async {
    final recorder = CompanionObservationRecorder();
    final observations = <CompanionObservation>[];
    final memories = <CompanionMemory>[];
    final observation = CompanionObservation(
      id: 'observation',
      childId: 'child',
      sessionId: 'session',
      type: CompanionObservationType.chosen,
      createdAt: DateTime(2026, 7, 15),
      momentId: 'idea',
    );

    await recorder.record(
      observation: observation,
      persist: (value) async => observations.add(value),
    );

    expect(observations, [observation]);
    expect(memories, isEmpty);
  });
}
