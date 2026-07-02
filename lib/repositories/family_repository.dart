import '../models/child_model.dart';
import '../models/family_model.dart';
import '../models/parent_model.dart';
import '../models/session_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class FamilyRepository {
  FamilyRepository({
    AuthService? authService,
    FirestoreService? firestoreService,
  }) : _authService = authService ?? AuthService(),
       _firestoreService = firestoreService ?? FirestoreService();

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<SessionModel> createFamily({
    required String familyName,
    required String parentName,
    required String email,
    required String password,
  }) async {
    final credential = await _authService.createAccount(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception("Impossible de créer le compte.");
    }

    final now = DateTime.now();

    final familyId = await _firestoreService.createFamily(
      FamilyModel(
        id: '',
        name: familyName,
        createdBy: user.uid,
        createdAt: now,
      ),
    );

    await _firestoreService.createParent(
      ParentModel(
        uid: user.uid,
        familyId: familyId,
        firstName: parentName,
        email: email,
        avatar: '',
        createdAt: now,
      ),
    );

    return SessionModel(
      userId: user.uid,
      familyId: familyId,
      firstName: parentName,
      email: email,
      avatar: '',
    );
  }

  Future<void> saveParentAvatar({
    required String familyId,
    required String parentId,
    required String avatarId,
  }) {
    return _firestoreService.updateParentAvatar(
      familyId: familyId,
      parentId: parentId,
      avatarId: avatarId,
    );
  }

  Future<void> createChild({
    required String familyId,
    required String firstName,
    required int age,
    required String avatar,
  }) async {
    final childId = _firestoreService.generateChildId(familyId);

    final child = ChildModel(
      id: childId,
      familyId: familyId,
      firstName: firstName,
      avatar: avatar,
      age: age,
      createdAt: DateTime.now(),
    );

    await _firestoreService.createChild(child);
  }

  Future<List<ChildModel>> getChildren({required String familyId}) {
    return _firestoreService.getChildren(familyId: familyId);
  }
}
