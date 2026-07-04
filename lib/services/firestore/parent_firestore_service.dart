import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/parent_model.dart';

class ParentFirestoreService {
  ParentFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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
}
