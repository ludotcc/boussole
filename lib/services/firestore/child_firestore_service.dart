import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/child_model.dart';

class ChildFirestoreService {
  ChildFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String generateChildId(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc()
        .id;
  }

  Future<void> createChild(ChildModel child) async {
    await _firestore
        .collection('families')
        .doc(child.familyId)
        .collection('children')
        .doc(child.id)
        .set({
          'id': child.id,
          'firstName': child.firstName,
          'avatar': child.avatar,
          'age': child.age,
          'createdAt': Timestamp.fromDate(child.createdAt),
        });
  }

  Future<List<ChildModel>> getChildren({required String familyId}) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .orderBy('createdAt')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return ChildModel(
        id: data['id'] as String,
        familyId: familyId,
        firstName: data['firstName'] as String,
        avatar: data['avatar'] as String,
        age: data['age'] as int,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }
}
