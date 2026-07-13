import 'child_model.dart';
import 'parent_model.dart';

enum FamilyMemberKind { adult, child }

class FamilyMemberModel {
  final String id;
  final String familyId;
  final String firstName;
  final int? age;
  final String avatar;
  final String profileType;
  final String? academyId;
  final Map<int, String> weeklyRhythmByWeekday;
  final FamilyMemberKind kind;
  final DateTime createdAt;

  const FamilyMemberModel({
    required this.id,
    required this.familyId,
    required this.firstName,
    required this.age,
    required this.avatar,
    required this.profileType,
    this.academyId,
    this.weeklyRhythmByWeekday = const {},
    required this.kind,
    required this.createdAt,
  });

  factory FamilyMemberModel.fromParent(ParentModel parent) {
    return FamilyMemberModel(
      id: parent.uid,
      familyId: parent.familyId,
      firstName: parent.firstName,
      age: parent.age,
      avatar: parent.avatar,
      profileType: parent.profileType,
      academyId: null,
      weeklyRhythmByWeekday: const {},
      kind: FamilyMemberKind.adult,
      createdAt: parent.createdAt,
    );
  }

  factory FamilyMemberModel.fromChild(ChildModel child) {
    return FamilyMemberModel(
      id: child.id,
      familyId: child.familyId,
      firstName: child.firstName,
      age: child.age,
      avatar: child.avatar,
      profileType: child.profileType,
      academyId: child.academyId,
      weeklyRhythmByWeekday: child.weeklyRhythmByWeekday,
      kind: FamilyMemberKind.child,
      createdAt: child.createdAt,
    );
  }

  bool get isAdult => kind == FamilyMemberKind.adult;
}
