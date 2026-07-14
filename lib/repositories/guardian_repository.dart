import '../models/guardian_model.dart';
import '../services/guardian_service.dart';

class GuardianRepository {
  GuardianRepository({GuardianService? service})
    : _service = service ?? GuardianService();

  final GuardianService _service;

  Future<GuardianModel> getGuardian({
    required String familyId,
    required String childId,
  }) async {
    final id = await _service.getGuardianId(
      familyId: familyId,
      childId: childId,
    );
    return GuardianModel.fromStorageId(id);
  }

  Future<void> selectGuardian({
    required String familyId,
    required String childId,
    required GuardianModel guardian,
  }) => _service.setGuardianId(
    familyId: familyId,
    childId: childId,
    guardianId: guardian.storageId,
  );
}
