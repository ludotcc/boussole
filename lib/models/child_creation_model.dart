import 'school_academy.dart';

class ChildCreationModel {
  final String firstName;
  final int age;
  final DateTime? birthDate;
  final String avatar;
  final String profileType;
  final String academyId;
  final Map<int, String> weeklyRhythmByWeekday;

  const ChildCreationModel({
    required this.firstName,
    required this.age,
    this.birthDate,
    required this.avatar,
    this.profileType = 'child',
    this.academyId = defaultSchoolAcademyId,
    this.weeklyRhythmByWeekday = const {
      DateTime.monday: 'school',
      DateTime.tuesday: 'school',
      DateTime.wednesday: 'wednesday',
      DateTime.thursday: 'school',
      DateTime.friday: 'school',
      DateTime.saturday: 'weekend',
      DateTime.sunday: 'weekend',
    },
  });

  ChildCreationModel copyWith({
    String? firstName,
    int? age,
    DateTime? birthDate,
    String? avatar,
    String? profileType,
    String? academyId,
    Map<int, String>? weeklyRhythmByWeekday,
  }) {
    return ChildCreationModel(
      firstName: firstName ?? this.firstName,
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
      avatar: avatar ?? this.avatar,
      profileType: profileType ?? this.profileType,
      academyId: academyId ?? this.academyId,
      weeklyRhythmByWeekday:
          weeklyRhythmByWeekday ?? this.weeklyRhythmByWeekday,
    );
  }
}
