import 'package:boussole/models/celebration.dart';
import 'package:boussole/models/child_model.dart';
import 'package:boussole/models/companion_child_experience.dart';
import 'package:boussole/models/child_day_item_model.dart';
import 'package:boussole/models/companion_memory.dart';
import 'package:boussole/models/companion_moment.dart';
import 'package:boussole/models/companion_suggestion_result.dart';
import 'package:boussole/services/companion_context_policy.dart';
import 'package:boussole/services/companion_dialogue_service.dart';
import 'package:boussole/providers/guardian_experience_provider.dart';
import 'package:boussole/models/guardian_model.dart';
import 'package:boussole/models/guardian_experience_state.dart';
import 'package:boussole/models/secret_mission.dart';
import 'package:boussole/widgets/child/companion_ideas_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche trois idees maximum et toujours Ma journee', (
    tester,
  ) async {
    await tester.pumpWidget(_app(experience: _experience(ideaCount: 4)));
    await tester.pump();

    expect(find.byKey(const ValueKey('companion-my-day')), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'companion-idea-',
            ),
      ),
      findsNWidgets(3),
    );
  });

  testWidgets(
    'une celebration reste affichee jusqu a sa fermeture volontaire',
    (tester) async {
      Celebration? dismissed;
      final celebration = Celebration.parentCreated(
        id: 'celebration',
        childId: 'child',
        type: CelebrationType.courage,
        parentId: 'parent',
        createdAt: DateTime(2026, 7, 15),
        shardReward: 0,
      );
      await tester.pumpWidget(
        _app(
          experience: _experience(celebration: celebration),
          onCelebrationDismissed: (value) => dismissed = value,
        ),
      );
      await tester.pump();

      await tester.pump(const Duration(minutes: 5));

      expect(find.byIcon(Icons.celebration_rounded), findsOneWidget);
      expect(dismissed, isNull);

      await tester.tap(
        find.byKey(const ValueKey('companion-celebration-continue')),
      );
      await tester.pump();

      expect(dismissed?.id, celebration.id);
      expect(find.byIcon(Icons.celebration_rounded), findsNothing);
      expect(find.byKey(const ValueKey('companion-my-day')), findsOneWidget);
    },
  );

  testWidgets('affiche le contenu principal sans scroll interne', (
    tester,
  ) async {
    await tester.pumpWidget(_app(experience: _experience()));
    await tester.pump();

    final panel = find.byKey(const ValueKey('companion-ideas-panel'));
    expect(
      find.descendant(of: panel, matching: find.byType(SingleChildScrollView)),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('companion-my-day')), findsOneWidget);
    expect(find.byKey(const ValueKey('companion-more-ideas')), findsOneWidget);
    expect(find.byKey(const ValueKey('companion-close')), findsOneWidget);
  });

  testWidgets('n affiche aucune celebration lorsqu elle est absente', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      _app(experience: _experience(), onCelebrationDismissed: (_) => calls++),
    );
    await tester.pump();

    expect(find.byIcon(Icons.celebration_rounded), findsNothing);
    expect(calls, 0);
  });

  testWidgets('une annonce de mission attend une fermeture volontaire', (
    tester,
  ) async {
    SecretMission? dismissed;
    final mission = _mission(reward: 5);
    await tester.pumpWidget(
      _app(
        experience: _experience(missionAnnouncement: mission),
        onMissionAnnouncementDismissed: (value) => dismissed = value,
      ),
    );
    await tester.pump(const Duration(minutes: 5));
    expect(find.byKey(const ValueKey('mission-announcement')), findsOneWidget);
    expect(dismissed, isNull);

    await tester.tap(
      find.byKey(const ValueKey('mission-announcement-continue')),
    );
    await tester.pump();
    expect(dismissed?.id, mission.id);
    expect(find.byKey(const ValueKey('mission-announcement')), findsNothing);
  });

  testWidgets('une celebration reste prioritaire sur une annonce de mission', (
    tester,
  ) async {
    final celebration = Celebration.parentCreated(
      id: 'celebration-priority',
      childId: 'child',
      type: CelebrationType.courage,
      parentId: 'parent',
      createdAt: DateTime(2026, 7, 15),
      shardReward: 0,
    );
    await tester.pumpWidget(
      _app(
        experience: _experience(
          celebration: celebration,
          missionAnnouncement: _mission(reward: 5),
        ),
      ),
    );
    expect(
      find.byKey(const ValueKey('companion-celebration-continue')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('mission-announcement')), findsNothing);
  });

  testWidgets('plusieurs annonces sont presentees une par une', (tester) async {
    final delivered = <String>[];
    await tester.pumpWidget(
      _app(
        experience: _experience(missionAnnouncement: _mission(reward: 5)),
        onMissionAnnouncementDismissed: (value) => delivered.add(value.id),
      ),
    );
    await tester.tap(
      find.byKey(const ValueKey('mission-announcement-continue')),
    );
    await tester.pump();

    await tester.pumpWidget(
      _app(
        experience: _experience(missionAnnouncement: _mission(reward: 7)),
        onMissionAnnouncementDismissed: (value) => delivered.add(value.id),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('mission-announcement')), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('mission-announcement-continue')),
    );

    expect(delivered, ['mission_5', 'mission_7']);
  });

  testWidgets('permet de choisir une idee', (tester) async {
    CompanionMoment? selected;
    await tester.pumpWidget(
      _app(experience: _experience(), onSelected: (idea) => selected = idea),
    );
    await tester.tap(find.byKey(const ValueKey('companion-idea-idea_0')));
    await tester.pump();

    expect(selected, isNull);
    expect(
      find.byKey(const ValueKey('companion-selected-idea')),
      findsOneWidget,
    );
    expect(find.text('Idée 0'), findsOneWidget);
    expect(find.text('Un beau moment à vivre.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('companion-selected-done')));
    expect(selected?.id, 'idea_0');
  });

  testWidgets('annuler revient aux propositions sans valider l idee', (
    tester,
  ) async {
    CompanionMoment? selected;
    await tester.pumpWidget(
      _app(experience: _experience(), onSelected: (idea) => selected = idea),
    );
    await tester.tap(find.byKey(const ValueKey('companion-idea-idea_0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('companion-selected-cancel')));
    await tester.pump();

    expect(selected, isNull);
    expect(find.byKey(const ValueKey('companion-my-day')), findsOneWidget);
    expect(find.byKey(const ValueKey('companion-idea-idea_0')), findsOneWidget);
  });

  testWidgets('permet de demander de nouvelles idees', (tester) async {
    var requests = 0;
    await tester.pumpWidget(
      _app(experience: _experience(), onNewIdeas: () => requests++),
    );
    await tester.tap(find.byKey(const ValueKey('companion-more-ideas')));

    expect(requests, 1);
  });

  testWidgets('ne contient aucune saisie texte', (tester) async {
    await tester.pumpWidget(_app(experience: _experience()));

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
  });

  test('utilise une memoire validee pertinente dans le dialogue', () {
    final now = DateTime(2026, 7, 15);
    final memory = CompanionMemory(
      id: 'memory',
      childId: 'child',
      type: CompanionMemoryType.likedActivity,
      value: 'aime construire',
      status: CompanionMemoryStatus.validated,
      priority: 2,
      reliability: .8,
      observationCount: 5,
      createdAt: now,
      updatedAt: now,
      lastObservedAt: now,
    );
    final dialogue = const CompanionDialogueService().suggestionDialogue(
      child: _child(),
      suggestions: CompanionSuggestionResult(
        ideas: [
          _idea(0, tags: const {'construire'}),
        ],
      ),
      validatedMemories: [memory],
    );

    expect(dialogue, contains('souvenu'));
    expect(dialogue, contains('Lina'));
  });

  test('adapte le besoin et le moment au contexte horaire', () {
    const policy = CompanionContextPolicy();
    final afterSchool = policy.buildDefaultRequest(
      childId: 'child',
      dateTime: DateTime(2026, 7, 15, 17),
    );
    final bedtime = policy.buildDefaultRequest(
      childId: 'child',
      dateTime: DateTime(2026, 7, 15, 21),
    );

    expect(afterSchool.mainMoment, 'afterSchool');
    expect(afterSchool.primaryNeed, CompanionNeed.findIdea);
    expect(bedtime.mainMoment, 'beforeBed');
    expect(bedtime.primaryNeed, CompanionNeed.rest);
  });

  test('calcule le temps disponible avant le prochain element du planning', () {
    const policy = CompanionContextPolicy();
    final short = policy.buildDefaultRequest(
      childId: 'child',
      dateTime: DateTime(2026, 7, 15, 15),
      dayItems: const [
        ChildDayItemModel(
          id: 'next',
          itemType: ChildDayItemType.moment,
          title: 'Suite',
          iconKey: 'clock',
          orderMinutes: 15 * 60 + 7,
          isSensitive: false,
        ),
      ],
    );
    final long = policy.buildDefaultRequest(
      childId: 'child',
      dateTime: DateTime(2026, 7, 15, 15),
      dayItems: const [
        ChildDayItemModel(
          id: 'later',
          itemType: ChildDayItemType.event,
          title: 'Plus tard',
          iconKey: 'clock',
          orderMinutes: 15 * 60 + 45,
          isSensitive: false,
        ),
      ],
    );

    expect(short.availableDurationMinutes, 7);
    expect(long.availableDurationMinutes, 45);
  });

  test('un seul clic ouvre immediatement un contenu utile', () {
    final notifier = GuardianExperienceNotifier(
      guardianId: GuardianId.crystal,
      now: () => DateTime(2026, 7, 15, 15),
    );
    addTearDown(notifier.dispose);

    notifier.openCompanion();

    expect(notifier.state.showChoices, isTrue);
    expect(notifier.state.choiceKind, GuardianChoiceKind.navigation);
  });

  test('le dialogue ne contient jamais de message d echec', () {
    final dialogue = const CompanionDialogueService().suggestionDialogue(
      child: _child(),
      suggestions: const CompanionSuggestionResult(ideas: []),
      validatedMemories: const [],
    );

    expect(dialogue.toLowerCase(), isNot(contains('aucune idée')));
    expect(dialogue.toLowerCase(), isNot(contains('pas d’idée')));
    expect(dialogue.toLowerCase(), isNot(contains('rien pour le moment')));
  });

  test('une Mission Secrete ne donne jamais d Eclat', () {
    const service = CompanionDialogueService();
    expect(
      service.missionValidatedDialogue(_mission(reward: 0)),
      'Ta Mission Secrète a été validée. Tu peux être fier de toi !',
    );
    expect(
      service.missionValidatedDialogue(_mission(reward: 1)),
      isNot(contains('Éclat')),
    );
    expect(
      service.missionValidatedDialogue(_mission(reward: 7)),
      isNot(contains('Éclat')),
    );
  });

  test('annonce exactement les Eclats d une celebration', () {
    const service = CompanionDialogueService();
    Celebration celebration(int reward) => Celebration(
      id: 'celebration_$reward',
      childId: 'child',
      type: CelebrationType.positiveBehavior,
      createdByParentId: 'parent',
      createdAt: DateTime(2026),
      shardReward: reward,
    );
    expect(
      service.celebrationDialogue(celebration(0)),
      isNot(contains('Éclat')),
    );
    expect(
      service.celebrationDialogue(celebration(1)),
      endsWith('J’ai aussi 1 Éclat pour toi.'),
    );
    expect(
      service.celebrationDialogue(celebration(4)),
      endsWith('J’ai aussi 4 Éclats pour toi.'),
    );
  });
}

Widget _app({
  required CompanionChildExperience experience,
  ValueChanged<CompanionMoment>? onSelected,
  VoidCallback? onNewIdeas,
  ValueChanged<Celebration>? onCelebrationDismissed,
  ValueChanged<SecretMission>? onMissionAnnouncementDismissed,
  VoidCallback? onClose,
}) => MaterialApp(
  home: Scaffold(
    body: CompanionIdeasPanel(
      experience: experience,
      onIdeaConfirmed: onSelected ?? (_) {},
      onNewIdeas: onNewIdeas ?? () {},
      onMyDay: () {},
      onClose: onClose ?? () {},
      onCelebrationDismissed: onCelebrationDismissed ?? (_) {},
      onMissionAnnouncementDismissed: onMissionAnnouncementDismissed ?? (_) {},
      onIdeasShown: (_) {},
    ),
  ),
);

CompanionChildExperience _experience({
  int ideaCount = 3,
  Celebration? celebration,
  SecretMission? missionAnnouncement,
}) => CompanionChildExperience(
  suggestions: CompanionSuggestionResult(
    ideas: [for (var index = 0; index < ideaCount; index++) _idea(index)],
  ),
  dialogue: celebration == null
      ? 'J’ai quelques idées pour toi. Tu peux choisir.'
      : 'Tu peux être fier de toi.',
  celebration: celebration,
  missionAnnouncement: missionAnnouncement,
);

SecretMission _mission({required int reward}) => SecretMission(
  id: 'mission_$reward',
  childId: 'child',
  catalogId: 'catalog',
  title: 'Mission',
  description: 'Description',
  category: SecretMissionCategory.helping,
  status: SecretMissionStatus.validated,
  createdAt: DateTime(2026, 7, 15),
  expiresAt: DateTime(2026, 7, 20),
  origin: SecretMissionOrigin.automatic,
  reward: reward,
  idempotencyKey: 'mission_$reward',
  validatedAt: DateTime(2026, 7, 15),
  announcementPending: true,
);

CompanionMoment _idea(int index, {Set<String> tags = const {}}) =>
    CompanionMoment(
      id: 'idea_$index',
      title: 'Idée $index',
      shortDescription: 'Un beau moment à vivre.',
      primaryNeed: CompanionNeed.findIdea,
      family: CompanionMomentFamily.values[index % 3],
      minimumAge: 3,
      maximumAge: 12,
      durationMinutes: 5,
      compatibleContexts: const {'home'},
      participants: CompanionParticipantContext.alone,
      tags: tags,
    );

ChildModel _child() => ChildModel(
  id: 'child',
  familyId: 'family',
  firstName: 'Lina',
  avatar: 'avatar',
  age: 8,
  createdAt: DateTime(2026),
);
