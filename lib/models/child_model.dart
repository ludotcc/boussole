import 'school_academy.dart';

class ChildModel {
  final String id;
  final String familyId;
  final String firstName;
  final String avatar;
  final int age;
  final String profileType;
  final String academyId;
  final Map<int, String> weeklyRhythmByWeekday;
  final DateTime createdAt;

  const ChildModel({
    required this.id,
    required this.familyId,
    required this.firstName,
    required this.avatar,
    required this.age,
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
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'firstName': firstName,
      'avatar': avatar,
      'age': age,
      'profileType': profileType,
      'academyId': academyId,
      'weeklyRhythmByWeekday': {
        for (final entry in weeklyRhythmByWeekday.entries)
          entry.key.toString(): entry.value,
      },
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      firstName: map['firstName'] as String,
      avatar: map['avatar'] as String,
      age: map['age'] as int,
      profileType: map['profileType'] as String? ?? 'child',
      academyId: map['academyId'] as String? ?? defaultSchoolAcademyId,
      weeklyRhythmByWeekday: weeklyRhythmFromMap(
        map['weeklyRhythmByWeekday'] as Map?,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  static Map<int, String> weeklyRhythmFromMap(Map? map) {
    if (map == null) {
      return const {
        DateTime.monday: 'school',
        DateTime.tuesday: 'school',
        DateTime.wednesday: 'wednesday',
        DateTime.thursday: 'school',
        DateTime.friday: 'school',
        DateTime.saturday: 'weekend',
        DateTime.sunday: 'weekend',
      };
    }

    return {
      DateTime.monday: map['1'] as String? ?? 'school',
      DateTime.tuesday: map['2'] as String? ?? 'school',
      DateTime.wednesday: map['3'] as String? ?? 'wednesday',
      DateTime.thursday: map['4'] as String? ?? 'school',
      DateTime.friday: map['5'] as String? ?? 'school',
      DateTime.saturday: map['6'] as String? ?? 'weekend',
      DateTime.sunday: map['7'] as String? ?? 'weekend',
    };
  }
}
