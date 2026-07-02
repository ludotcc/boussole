class ChildCreationModel {
  final String firstName;
  final int age;
  final String avatar;

  const ChildCreationModel({
    required this.firstName,
    required this.age,
    required this.avatar,
  });

  ChildCreationModel copyWith({String? firstName, int? age, String? avatar}) {
    return ChildCreationModel(
      firstName: firstName ?? this.firstName,
      age: age ?? this.age,
      avatar: avatar ?? this.avatar,
    );
  }
}
