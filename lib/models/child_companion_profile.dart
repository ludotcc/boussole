class ChildCompanionProfile {
  const ChildCompanionProfile({
    this.interests = const [],
    this.likedActivities = const [],
    this.helpfulApproaches = const [],
    this.difficultSituations = const [],
    this.parentGoals = const [],
    this.specialNeeds = const [],
    this.sensitiveSituations = const [],
    this.activitiesToAvoid = const [],
  });

  final List<String> interests;
  final List<String> likedActivities;
  final List<String> helpfulApproaches;
  final List<String> difficultSituations;
  final List<String> parentGoals;
  final List<String> specialNeeds;
  final List<String> sensitiveSituations;
  final List<String> activitiesToAvoid;

  Map<String, dynamic> toMap() => {
    'interests': interests,
    'likedActivities': likedActivities,
    'helpfulApproaches': helpfulApproaches,
    'difficultSituations': difficultSituations,
    'parentGoals': parentGoals.take(3).toList(),
    'specialNeeds': specialNeeds,
    'sensitiveSituations': specialNeeds.isEmpty
        ? <String>[]
        : sensitiveSituations,
    'activitiesToAvoid': activitiesToAvoid,
  };

  factory ChildCompanionProfile.fromMap(Map? map) {
    List<String> values(String key) =>
        (map?[key] as List?)?.whereType<String>().toList() ?? const [];

    final specialNeeds = values('specialNeeds');
    return ChildCompanionProfile(
      interests: values('interests'),
      likedActivities: values('likedActivities'),
      helpfulApproaches: values('helpfulApproaches'),
      difficultSituations: values('difficultSituations'),
      parentGoals: values('parentGoals').take(3).toList(),
      specialNeeds: specialNeeds,
      sensitiveSituations: specialNeeds.isEmpty
          ? const []
          : values('sensitiveSituations'),
      activitiesToAvoid: values('activitiesToAvoid'),
    );
  }
}
