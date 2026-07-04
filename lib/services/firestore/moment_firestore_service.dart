import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/moment_model.dart';

class MomentFirestoreService {
  MomentFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String generateMomentId(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('moments')
        .doc()
        .id;
  }

  Future<int> getNextMomentPosition({required String familyId}) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('moments')
        .orderBy('position', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    final data = snapshot.docs.first.data();

    return (data['position'] as int) + 1;
  }

  Future<void> createMoment({
    required String familyId,
    required MomentModel moment,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('moments')
        .doc(moment.id)
        .set(moment.toMap());
  }

  Future<List<MomentModel>> getMoments({required String familyId}) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('moments')
        .orderBy('position')
        .get();

    return snapshot.docs.map((doc) => MomentModel.fromMap(doc.data())).toList();
  }

  Future<void> updateMoment({
    required String familyId,
    required MomentModel moment,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('moments')
        .doc(moment.id)
        .update(moment.toMap());
  }

  Future<void> updateMomentPosition({
    required String familyId,
    required String momentId,
    required int position,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('moments')
        .doc(momentId)
        .update({'position': position});
  }

  Future<void> deleteMoment({
    required String familyId,
    required String momentId,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('moments')
        .doc(momentId)
        .delete();
  }
}
