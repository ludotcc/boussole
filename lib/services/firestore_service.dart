import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/child_model.dart';
import '../models/day_exception_model.dart';
import '../models/day_type_model.dart';
import '../models/family_model.dart';
import '../models/parent_model.dart';
import '../models/moment_model.dart';
import '../models/routine_model.dart';
import '../models/step_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createFamily(FamilyModel family) async {
    final doc = _firestore.collection('families').doc();

    await doc.set({
      'info': {
        'name': family.name,
        'ownerUid': family.createdBy,
        'createdAt': Timestamp.fromDate(family.createdAt),
      },
    });

    return doc.id;
  }

  Future<void> createParent(ParentModel parent) async {
    await _firestore
        .collection('families')
        .doc(parent.familyId)
        .collection('members')
        .doc(parent.uid)
        .set({
          'uid': parent.uid,
          'firstName': parent.firstName,
          'email': parent.email,
          'avatar': parent.avatar,
          'createdAt': Timestamp.fromDate(parent.createdAt),
          'role': 'parent',
        });
  }

  Future<void> updateParentAvatar({
    required String familyId,
    required String parentId,
    required String avatarId,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('members')
        .doc(parentId)
        .update({'avatar': avatarId});
  }

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

  Future<ParentModel?> getParent({
    required String familyId,
    required String parentId,
  }) async {
    final doc = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('members')
        .doc(parentId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;

    return ParentModel(
      uid: data['uid'] as String,
      familyId: familyId,
      firstName: data['firstName'] as String,
      email: data['email'] as String,
      avatar: data['avatar'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Future<void> createUserIndex({
    required String uid,
    required String familyId,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'familyId': familyId,
      'role': 'parent',
      'createdAt': Timestamp.now(),
    });
  }

  /// Retourne le familyId associé à un utilisateur.
  /// Renvoie null si aucun index n'existe.
  Future<String?> getFamilyIdFromUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return data['familyId'] as String?;
  }

  // ---------------------------------------------------------------------------
  // Journées Types
  // ---------------------------------------------------------------------------

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

    return snapshot.docs.map((doc) {
      return DayTypeModel.fromMap(doc.data());
    }).toList();
  }

  Future<DayTypeModel?> getDayTypeByType({
    required String familyId,
    required String type,
  }) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('day_types')
        .where('type', isEqualTo: type)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return DayTypeModel.fromMap(snapshot.docs.first.data());
  }

  Future<void> updateDayType(DayTypeModel dayType) async {
    await _firestore
        .collection('families')
        .doc(dayType.familyId)
        .collection('day_types')
        .doc(dayType.id)
        .update(dayType.toMap());
  }

  // ---------------------------------------------------------------------------
  // Exceptions de journées
  // ---------------------------------------------------------------------------

  String generateDayExceptionId(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('day_exceptions')
        .doc()
        .id;
  }

  Future<void> createDayException(DayExceptionModel dayException) async {
    await _firestore
        .collection('families')
        .doc(dayException.familyId)
        .collection('day_exceptions')
        .doc(dayException.id)
        .set(dayException.toMap());
  }

  Future<void> updateDayException(DayExceptionModel dayException) async {
    await _firestore
        .collection('families')
        .doc(dayException.familyId)
        .collection('day_exceptions')
        .doc(dayException.id)
        .update(dayException.toMap());
  }

  Future<List<DayExceptionModel>> getDayExceptions({
    required String familyId,
  }) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('day_exceptions')
        .orderBy('dateKey')
        .get();

    return snapshot.docs
        .map((doc) => DayExceptionModel.fromMap(doc.data()))
        .toList();
  }

  Future<DayExceptionModel?> getDayExceptionByDate({
    required String familyId,
    required String dateKey,
  }) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('day_exceptions')
        .where('dateKey', isEqualTo: dateKey)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return DayExceptionModel.fromMap(snapshot.docs.first.data());
  }

  // ---------------------------------------------------------------------------
  // Moments
  // ---------------------------------------------------------------------------

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

  Future<void> updateMomentPositions({
    required String familyId,
    required Map<String, int> positionsByMomentId,
  }) async {
    final batch = _firestore.batch();
    final momentsRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('moments');

    for (final entry in positionsByMomentId.entries) {
      batch.update(momentsRef.doc(entry.key), {'position': entry.value});
    }

    await batch.commit();
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
  // ---------------------------------------------------------------------------
  // Routines
  // ---------------------------------------------------------------------------

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

  Future<List<RoutineModel>> getRoutinesForMoment({
    required String familyId,
    required String momentId,
  }) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .where('momentId', isEqualTo: momentId)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => RoutineModel.fromMap(doc.data()))
        .toList();
  }

  Future<int> getNextRoutineOrder({
    required String familyId,
    required String momentId,
  }) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .where('momentId', isEqualTo: momentId)
        .orderBy('order', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    final data = snapshot.docs.first.data();

    return (data['order'] as int) + 1;
  }

  Future<RoutineModel?> getRoutine({
    required String familyId,
    required String routineId,
  }) async {
    final doc = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc(routineId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return RoutineModel.fromMap(data);
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

  Future<void> updateRoutineOrders({
    required String familyId,
    required Map<String, int> ordersByRoutineId,
  }) async {
    final batch = _firestore.batch();
    final routinesRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines');

    for (final entry in ordersByRoutineId.entries) {
      batch.update(routinesRef.doc(entry.key), {'order': entry.value});
    }

    await batch.commit();
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
  // ---------------------------------------------------------------------------
  // Étapes
  // ---------------------------------------------------------------------------

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

  Future<int> getNextStepOrder({
    required String familyId,
    required String routineId,
  }) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc(routineId)
        .collection('steps')
        .orderBy('order', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    final data = snapshot.docs.first.data();

    return (data['order'] as int) + 1;
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

  Future<void> updateStepOrders({
    required String familyId,
    required String routineId,
    required Map<String, int> ordersByStepId,
  }) async {
    final batch = _firestore.batch();
    final stepsRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('routines')
        .doc(routineId)
        .collection('steps');

    for (final entry in ordersByStepId.entries) {
      batch.update(stepsRef.doc(entry.key), {'order': entry.value});
    }

    await batch.commit();
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
