import 'package:cloud_firestore/cloud_firestore.dart';

class GuardianService {
  GuardianService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _child({
    required String familyId,
    required String childId,
  }) => _firestore
      .collection('families')
      .doc(familyId)
      .collection('children')
      .doc(childId);

  Future<String?> getGuardianId({
    required String familyId,
    required String childId,
  }) async {
    final snapshot = await _child(familyId: familyId, childId: childId).get();
    return snapshot.data()?['guardianId'] as String?;
  }

  Future<void> setGuardianId({
    required String familyId,
    required String childId,
    required String guardianId,
  }) => _child(
    familyId: familyId,
    childId: childId,
  ).update({'guardianId': guardianId});
}
