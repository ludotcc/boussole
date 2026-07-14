enum GuardianPose {
  welcome,
  talking,
  choices,
  encourage,
  reassure,
  celebrate,
  idle,
  sleeping,
}

enum GuardianChoiceKind { navigation, secretMission }

class GuardianExperienceState {
  const GuardianExperienceState({
    required this.pose,
    required this.message,
    this.showChoices = false,
    this.choiceKind = GuardianChoiceKind.navigation,
  });

  final GuardianPose pose;
  final String message;
  final bool showChoices;
  final GuardianChoiceKind choiceKind;

  bool get isSleeping => pose == GuardianPose.sleeping;
}
