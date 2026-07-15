import '../models/guardian_model.dart';
import '../models/guardian_ownership.dart';
import '../services/guardian_service.dart';

class GuardianRepository {
  GuardianRepository({GuardianService? service})
    : _service = service ?? GuardianService();

  final GuardianService _service;

  Future<GuardianModel> getGuardian({
    required String familyId,
    required String childId,
  }) async {
    final ownership = await _service.getOwnership(
      familyId: familyId,
      childId: childId,
    );
    return GuardianModel.fromStorageId(
      ownership.selectedId.name,
      fallback: GuardianId.wave,
    );
  }

  Future<GuardianOwnership> getOwnership({
    required String familyId,
    required String childId,
  }) => _service.getOwnership(familyId: familyId, childId: childId);

  Future<GuardianSelectionResult> selectGuardian({
    required String familyId,
    required String childId,
    required GuardianModel guardian,
  }) => _service.selectGuardian(
    familyId: familyId,
    childId: childId,
    guardianId: guardian.storageId,
  );

  Future<GuardianPurchaseResult> purchaseGuardian({
    required String familyId,
    required String childId,
    required GuardianModel guardian,
  }) => _service.purchaseGuardian(
    familyId: familyId,
    childId: childId,
    guardian: guardian,
  );
}
