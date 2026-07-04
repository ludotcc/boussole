import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/step_model.dart';

class StepFirestoreService {
  StepFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String generateStepId({required String familyId, required String routineId}) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc(routineId)
        .collection('steps')
        .doc()
        .id;
  }

  Future<void> createStep({
    required String familyId,
    required String routineId,
    required StepModel step,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc(routineId)
        .collection('steps')
        .doc(step.id)
        .set(step.toMap());
  }

  Future<List<StepModel>> getSteps({
    required String familyId,
    required String routineId,
  }) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc(routineId)
        .collection('steps')
        .orderBy('order')
        .get();

    return snapshot.docs.map((doc) => StepModel.fromMap(doc.data())).toList();
  }

  Future<void> updateStep({
    required String familyId,
    required String routineId,
    required StepModel step,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc(routineId)
        .collection('steps')
        .doc(step.id)
        .update(step.toMap());
  }

  Future<void> deleteStep({
    required String familyId,
    required String routineId,
    required String stepId,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc(routineId)
        .collection('steps')
        .doc(stepId)
        .delete();
  }
}
