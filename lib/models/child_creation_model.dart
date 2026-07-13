import 'school_academy.dart';

class ChildCreationModel {
  final String firstName;
  final int age;
  final String avatar;
  final String profileType;
  final String academyId;
  final Map<int, String> weeklyRhythmByWeekday;

  const ChildCreationModel({
    required this.firstName,
    required this.age,
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
    String? avatar,
    String? profileType,
    String? academyId,
    Map<int, String>? weeklyRhythmByWeekday,
  }) {
    return ChildCreationModel(
      firstName: firstName ?? this.firstName,
      age: age ?? this.age,
      avatar: avatar ?? this.avatar,
      profileType: profileType ?? this.profileType,
      academyId: academyId ?? this.academyId,
      weeklyRhythmByWeekday:
          weeklyRhythmByWeekday ?? this.weeklyRhythmByWeekday,
    );
  }
}
