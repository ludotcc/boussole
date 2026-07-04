import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/day_type_model.dart';

class DayTypeFirestoreService {
  DayTypeFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String generateDayTypeId(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('day_types')
        .doc()
        .id;
  }

  Future<void> createDayType(DayTypeModel dayType) async {
    await _firestore
        .collection('families')
        .doc(dayType.familyId)
        .collection('day_types')
        .doc(dayType.id)
        .set(dayType.toMap());
  }

  Future<List<DayTypeModel>> getDayTypes({required String familyId}) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('day_types')
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => DayTypeModel.fromMap(doc.data()))
        .toList();
  }
}
