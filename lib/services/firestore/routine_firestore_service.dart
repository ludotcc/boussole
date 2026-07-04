import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/routine_model.dart';

class RoutineFirestoreService {
  RoutineFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String generateRoutineId(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc()
        .id;
  }

  Future<void> createRoutine({
    required String familyId,
    required RoutineModel routine,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc(routine.id)
        .set(routine.toMap());
  }

  Future<List<RoutineModel>> getRoutines({required String familyId}) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .get();

    return snapshot.docs
        .map((doc) => RoutineModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateRoutine({
    required String familyId,
    required RoutineModel routine,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc(routine.id)
        .update(routine.toMap());
  }

  Future<void> deleteRoutine({
    required String familyId,
    required String routineId,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc(routineId)
        .delete();
  }
}
