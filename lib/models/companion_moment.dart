enum CompanionNeed {
  findIdea,
  create,
  move,
  calmDown,
  wait,
  share,
  help,
  explore,
  learn,
  buildConfidence,
  celebrate,
  rest,
}

enum CompanionMomentFamily {
  create,
  build,
  draw,
  craft,
  cook,
  garden,
  read,
  write,
  imagine,
  observe,
  explore,
  experiment,
  move,
  dance,
  music,
  play,
  think,
  share,
  help,
  celebrate,
  relax,
}

enum CompanionParticipantContext { alone, withParent, withSibling, family }

class CompanionMoment {
  const CompanionMoment({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.primaryNeed,
    required this.family,
    required this.minimumAge,
    required this.maximumAge,
    required this.durationMinutes,
    required this.compatibleContexts,
    this.compatibleMainMoments = const {},
    required this.participants,
    this.requiredMaterials = const {},
    this.compatibleParentGoals = const {},
    this.compatibleInterests = const {},
    this.incompatibleAvoidedActivities = const {},
    this.incompatibleSensitiveSituations = const {},
    this.tags = const {},
    this.isSafe = true,
    this.active = true,
  });

  final String id;
  final String title;
  final String shortDescription;
  final CompanionNeed primaryNeed;
  final CompanionMomentFamily family;
  final int minimumAge;
  final int maximumAge;
  final int durationMinutes;
  final Set<String> compatibleContexts;
  final Set<String> compatibleMainMoments;
  final CompanionParticipantContext participants;
  final Set<String> requiredMaterials;
  final Set<String> compatibleParentGoals;
  final Set<String> compatibleInterests;
  final Set<String> incompatibleAvoidedActivities;
  final Set<String> incompatibleSensitiveSituations;
  final Set<String> tags;
  final bool isSafe;
  final bool active;
}
