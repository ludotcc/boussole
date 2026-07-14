import 'package:cloud_firestore/cloud_firestore.dart';

class SharedMoment {
  const SharedMoment({
    required this.id,
    required this.childId,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.guardianId,
    required this.origin,
    required this.validatedByParent,
    required this.iconId,
    this.missionId,
  });
  final String id;
  final String childId;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String guardianId;
  final String origin;
  final bool validatedByParent;
  final String iconId;
  final String? missionId;

  Map<String, dynamic> toMap() => {
    'id': id,
    'childId': childId,
    'title': title,
    'description': description,
    'category': category,
    'date': Timestamp.fromDate(date),
    'guardianId': guardianId,
    'origin': origin,
    'validatedByParent': validatedByParent,
    'iconId': iconId,
    'missionId': missionId,
  };
  factory SharedMoment.fromMap(String id, Map<String, dynamic> map) =>
      SharedMoment(
        id: id,
        childId: map['childId'] as String? ?? '',
        title: map['title'] as String? ?? 'Un beau moment',
        description: map['description'] as String? ?? '',
        category: map['category'] as String? ?? 'family',
        date: map['date'] is Timestamp
            ? (map['date'] as Timestamp).toDate()
            : DateTime.fromMillisecondsSinceEpoch(0),
        guardianId: map['guardianId'] as String? ?? 'crystal',
        origin: map['origin'] as String? ?? 'secretMission',
        validatedByParent: map['validatedByParent'] as bool? ?? true,
        iconId: map['iconId'] as String? ?? 'favorite',
        missionId: map['missionId'] as String?,
      );
}
