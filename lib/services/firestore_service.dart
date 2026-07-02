import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/child_model.dart';
import '../models/family_model.dart';
import '../models/parent_model.dart';

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
}
