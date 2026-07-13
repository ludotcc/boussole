enum PlanningDayKind {
  school,
  wednesday,
  weekend,
  vacation;

  static PlanningDayKind fromValue(String? value) {
    return switch (value) {
      'school' || 'schoolDay' => PlanningDayKind.school,
      'wednesday' => PlanningDayKind.wednesday,
      'weekend' || 'noSchoolDay' => PlanningDayKind.weekend,
      'vacation' => PlanningDayKind.vacation,
      _ => PlanningDayKind.school,
    };
  }

  String get value {
    return switch (this) {
      PlanningDayKind.school => 'school',
      PlanningDayKind.wednesday => 'wednesday',
      PlanningDayKind.weekend => 'weekend',
      PlanningDayKind.vacation => 'vacation',
    };
  }

  String get label {
    return switch (this) {
      PlanningDayKind.school => 'Sa journée d\'école',
      PlanningDayKind.wednesday => 'Son mercredi',
      PlanningDayKind.weekend => 'Son week-end',
      PlanningDayKind.vacation => 'Ses vacances',
    };
  }

  String get childDayText {
    return switch (this) {
      PlanningDayKind.school => "Aujourd'hui, c'est une journée d'ecole.",
      PlanningDayKind.wednesday => "Aujourd'hui, c'est mercredi.",
      PlanningDayKind.weekend => "Aujourd'hui, c'est le week-end.",
      PlanningDayKind.vacation => "Aujourd'hui, c'est les vacances.",
    };
  }
}
