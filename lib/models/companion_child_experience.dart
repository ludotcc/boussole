import 'celebration.dart';
import 'companion_suggestion_result.dart';
import 'secret_mission.dart';

class CompanionChildExperience {
  const CompanionChildExperience({
    required this.suggestions,
    required this.dialogue,
    this.celebration,
    this.missionAnnouncement,
  });

  final CompanionSuggestionResult suggestions;
  final String dialogue;
  final Celebration? celebration;
  final SecretMission? missionAnnouncement;
}
