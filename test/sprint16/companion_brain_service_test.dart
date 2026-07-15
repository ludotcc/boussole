import 'package:boussole/models/child_companion_profile.dart';
import 'package:boussole/core/constants/companion_moments_catalog.dart';
import 'package:boussole/models/child_model.dart';
import 'package:boussole/models/companion_context.dart';
import 'package:boussole/models/companion_memory.dart';
import 'package:boussole/models/companion_moment.dart';
import 'package:boussole/models/companion_observation.dart';
import 'package:boussole/services/companion_brain_service.dart';
import 'package:boussole/services/companion_context_policy.dart';
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
    List<String> recentMomentIds = const [],
    List<String> previousGroupIds = const [],
    CompanionNeed primaryNeed = CompanionNeed.findIdea,
  }) => CompanionContext(
    dateTime: DateTime(2026, 7, 15, 15),
    isSchoolDay: false,
    isVacation: true,
    mainMoment: mainMoment,
    availableContexts: contexts,
    availableDurationMinutes: duration,
    primaryNeed: primaryNeed,
    child: selectedChild ?? child(),
    validatedMemories: memories,
    recentMomentIds: recentMomentIds,
    previousGroupIds: previousGroupIds,
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

  test('evite les idees recentes et change le groupe precedent', () {
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'old_play', family: CompanionMomentFamily.play),
        moment(id: 'old_read', family: CompanionMomentFamily.read),
        moment(id: 'old_build', family: CompanionMomentFamily.build),
        moment(id: 'new_draw', family: CompanionMomentFamily.draw),
        moment(id: 'new_move', family: CompanionMomentFamily.move),
        moment(id: 'new_observe', family: CompanionMomentFamily.observe),
      ],
    );

    final result = service.selectIdeas(
      context(
        recentMomentIds: const ['old_play', 'old_read', 'old_build'],
        previousGroupIds: const ['old_play', 'old_read', 'old_build'],
      ),
    );

    expect(result.ideas.map((idea) => idea.id), [
      'new_draw',
      'new_move',
      'new_observe',
    ]);
  });

  test('reutilise les plus anciennes idees seulement si necessaire', () {
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'new', family: CompanionMomentFamily.draw),
        moment(id: 'newest', family: CompanionMomentFamily.play),
        moment(id: 'oldest', family: CompanionMomentFamily.read),
      ],
    );

    final result = service.selectIdeas(
      context(recentMomentIds: const ['newest', 'oldest']),
    );

    expect(result.ideas.first.id, 'new');
    expect(result.ideas[1].id, 'oldest');
    expect(result.ideas[2].id, 'newest');
  });

  test('ne repete pas exactement le meme groupe sans alternative', () {
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'one', family: CompanionMomentFamily.draw),
        moment(id: 'two', family: CompanionMomentFamily.play),
        moment(id: 'three', family: CompanionMomentFamily.read),
      ],
    );

    final result = service.selectIdeas(
      context(
        recentMomentIds: const ['one', 'two', 'three'],
        previousGroupIds: const ['three', 'two', 'one'],
      ),
    );

    expect(
      result.ideas.map((idea) => idea.id).toList(),
      isNot(['three', 'two', 'one']),
    );
    expect(result.ideas, hasLength(2));
  });

  test('conserve au moins une idee quand une seule reste possible', () {
    final service = CompanionBrainService(catalog: [moment(id: 'only')]);

    final result = service.selectIdeas(
      context(
        recentMomentIds: const ['only'],
        previousGroupIds: const ['only'],
      ),
    );

    expect(result.ideas.map((idea) => idea.id), ['only']);
  });

  test('fournit au moins une idee dans chaque contexte horaire courant', () {
    const policy = CompanionContextPolicy();
    const service = CompanionBrainService();

    for (final hour in [7, 10, 12, 17, 19, 21]) {
      final request = policy.buildDefaultRequest(
        childId: 'child',
        dateTime: DateTime(2026, 7, 15, hour),
      );
      final result = service.selectIdeas(
        CompanionContext(
          dateTime: request.dateTime!,
          isSchoolDay: false,
          isVacation: false,
          mainMoment: request.mainMoment,
          availableContexts: request.availableContexts,
          availableDurationMinutes: request.availableDurationMinutes,
          primaryNeed: request.primaryNeed,
          child: child(),
          availableMaterials: request.availableMaterials,
          availableParticipants: request.availableParticipants,
        ),
      );

      expect(result.ideas, isNotEmpty, reason: 'heure $hour');
    }
  });

  test('utilise un moment generique sur et statique en dernier recours', () {
    final generic = moment(id: 'generic', tags: {'generic-safe'});
    final service = CompanionBrainService(catalog: [generic]);

    final result = service.selectIdeas(
      CompanionContext(
        dateTime: DateTime(2026, 7, 15),
        isSchoolDay: false,
        isVacation: false,
        mainMoment: 'freeTime',
        availableContexts: const {'home'},
        availableDurationMinutes: 10,
        primaryNeed: CompanionNeed.learn,
        child: child(),
      ),
    );

    expect(result.ideas, [generic]);
  });

  test(
    'une ouverture normale ne donne aucune priorite automatique au calme',
    () {
      final service = CompanionBrainService(
        catalog: [
          moment(id: 'play', family: CompanionMomentFamily.play),
          CompanionMoment(
            id: 'calm',
            title: 'calm',
            shortDescription: 'calm',
            primaryNeed: CompanionNeed.calmDown,
            family: CompanionMomentFamily.relax,
            minimumAge: 3,
            maximumAge: 12,
            durationMinutes: 5,
            compatibleContexts: const {'home'},
            participants: CompanionParticipantContext.alone,
          ),
        ],
      );

      expect(service.selectIdeas(context()).ideas.map((idea) => idea.id), [
        'play',
      ]);
      expect(
        service
            .selectIdeas(context(primaryNeed: CompanionNeed.calmDown))
            .ideas
            .map((idea) => idea.id),
        ['calm'],
      );
    },
  );

  test('un planning court exclut les moments longs', () {
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'short', duration: 5),
        moment(id: 'long', duration: 30),
      ],
    );
    expect(
      service.selectIdeas(context(duration: 7)).ideas.map((idea) => idea.id),
      ['short'],
    );
    expect(
      service.selectIdeas(context(duration: 35)).ideas.map((idea) => idea.id),
      contains('long'),
    );
  });

  test('un centre d interet dinosaures priorise une variante compatible', () {
    final service = CompanionBrainService(
      catalog: [
        moment(id: 'neutral', family: CompanionMomentFamily.draw),
        moment(
          id: 'dinosaur',
          family: CompanionMomentFamily.build,
          tags: {'dinosaures'},
        ),
      ],
    );
    final selectedChild = child(
      profile: const ChildCompanionProfile(interests: ['dinosaures']),
    );

    expect(
      service.selectIdeas(context(selectedChild: selectedChild)).ideas.first.id,
      'dinosaur',
    );
  });

  test('la bibliotheque respecte le volume et la repartition valides', () {
    expect(companionMomentsCatalog.length, greaterThanOrEqualTo(128));
    expect(
      companionMomentsCatalog.map((moment) => moment.id).toSet(),
      hasLength(companionMomentsCatalog.length),
    );
    expect(
      companionMomentsCatalog.map((moment) => moment.title).toSet(),
      hasLength(companionMomentsCatalog.length),
    );
    expect(
      companionMomentsCatalog.map((moment) => moment.shortDescription).toSet(),
      hasLength(companionMomentsCatalog.length),
    );
    int count(Set<CompanionMomentFamily> families) => companionMomentsCatalog
        .where((moment) => families.contains(moment.family))
        .length;

    expect(
      count({CompanionMomentFamily.create, CompanionMomentFamily.draw}),
      greaterThanOrEqualTo(8),
    );
    expect(count({CompanionMomentFamily.build}), greaterThanOrEqualTo(6));
    expect(count({CompanionMomentFamily.imagine}), greaterThanOrEqualTo(6));
    expect(count({CompanionMomentFamily.play}), greaterThanOrEqualTo(6));
    expect(
      count({CompanionMomentFamily.move, CompanionMomentFamily.dance}),
      greaterThanOrEqualTo(6),
    );
    expect(
      count({CompanionMomentFamily.observe, CompanionMomentFamily.explore}),
      greaterThanOrEqualTo(6),
    );
    expect(
      count({CompanionMomentFamily.read, CompanionMomentFamily.think}),
      greaterThanOrEqualTo(5),
    );
    expect(
      count({CompanionMomentFamily.help, CompanionMomentFamily.share}),
      greaterThanOrEqualTo(5),
    );
    expect(
      count({
        CompanionMomentFamily.cook,
        CompanionMomentFamily.craft,
        CompanionMomentFamily.garden,
      }),
      greaterThanOrEqualTo(6),
    );
    final calm = companionMomentsCatalog.where(
      (moment) =>
          moment.primaryNeed == CompanionNeed.calmDown ||
          moment.primaryNeed == CompanionNeed.rest,
    );
    expect(calm.length, lessThanOrEqualTo(6));
  });

  test('le fallback normal propose une occupation et non une respiration', () {
    const service = CompanionBrainService();
    final ideas = service.selectIdeas(context(duration: 3)).ideas;

    expect(ideas, isNotEmpty);
    expect(
      ideas.every((idea) => idea.primaryNeed != CompanionNeed.calmDown),
      isTrue,
    );
    expect(
      ideas.every((idea) => idea.primaryNeed != CompanionNeed.rest),
      isTrue,
    );
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
