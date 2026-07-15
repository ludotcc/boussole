import 'guardian_model.dart';

class GuardianOwnership {
  const GuardianOwnership({required this.selectedId, required this.ownedIds});

  final GuardianId selectedId;
  final Set<GuardianId> ownedIds;

  bool owns(GuardianId id) => id == GuardianId.wave || ownedIds.contains(id);

  factory GuardianOwnership.fromChildData(Map<String, dynamic>? data) {
    final selected = GuardianModel.fromStorageId(
      data?['guardianId'] as String?,
      fallback: GuardianId.wave,
    ).id;
    final rawOwned = data?['ownedGuardianIds'] as List? ?? const [];
    final owned =
        rawOwned
            .whereType<String>()
            .map(
              (id) =>
                  GuardianModel.fromStorageId(id, fallback: GuardianId.wave).id,
            )
            .toSet()
          ..add(GuardianId.wave)
          ..add(selected);
    return GuardianOwnership(selectedId: selected, ownedIds: owned);
  }
}
