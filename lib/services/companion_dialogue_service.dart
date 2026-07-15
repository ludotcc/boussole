import '../models/celebration.dart';
import '../models/child_model.dart';
import '../models/companion_memory.dart';
import '../models/companion_suggestion_result.dart';
import '../models/secret_mission.dart';

class CompanionDialogueService {
  const CompanionDialogueService();

  String suggestionDialogue({
    required ChildModel child,
    required CompanionSuggestionResult suggestions,
    required List<CompanionMemory> validatedMemories,
  }) {
    for (final memory in validatedMemories) {
      final normalized = memory.value.toLowerCase();
      final isRelevant = suggestions.ideas.any(
        (idea) =>
            idea.tags.any((tag) => normalized.contains(tag.toLowerCase())),
      );
      if (isRelevant) {
        return 'Je me suis souvenu de quelque chose que tu aimes, ${child.firstName}. Tu peux choisir.';
      }
    }
    if (suggestions.ideas.isEmpty) {
      return 'Ma journée est toujours là pour toi, ${child.firstName}.';
    }
    return 'J’ai ${suggestions.ideas.length == 1 ? 'une idée' : 'quelques idées'} pour toi, ${child.firstName}. Tu peux choisir.';
  }

  String celebrationDialogue(Celebration celebration) {
    final message = switch (celebration.type) {
      CelebrationType.courage =>
        'Tes parents m’ont raconté ton courage. Tu peux être fier de toi.',
      CelebrationType.patience =>
        'Tes parents m’ont raconté ta patience. Tu peux être fier de toi.',
      CelebrationType.autonomy =>
        'Tes parents m’ont raconté les efforts que tu as faits tout seul.',
      CelebrationType.respect || CelebrationType.politeness =>
        'Tes parents m’ont raconté ton beau comportement.',
      CelebrationType.emotionManagement =>
        'Tes parents m’ont raconté les efforts que tu as faits dans un moment difficile.',
      CelebrationType.perseverance =>
        'Tes parents m’ont raconté que tu as persévéré. Bravo pour tes efforts.',
      CelebrationType.helping =>
        'Tes parents m’ont raconté le beau moment d’entraide que tu as créé.',
      CelebrationType.initiative =>
        'Tes parents m’ont raconté ta belle initiative.',
      CelebrationType.positiveBehavior =>
        'Tes parents m’ont raconté ton très beau comportement. Tu peux être fier de toi.',
    };
    if (celebration.shardReward == 0) return message;
    final amount = celebration.shardReward;
    return '$message J’ai aussi $amount Éclat${amount > 1 ? 's' : ''} pour toi.';
  }

  String chosenDialogue() => 'Passe un bon moment.';

  String missionValidatedDialogue(SecretMission mission) {
    const start =
        'Ta Mission Secrète a été validée. Tu peux être fier de toi !';
    return start;
  }
}
