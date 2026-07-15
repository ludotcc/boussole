import 'package:boussole/models/guardian_model.dart';
import 'package:boussole/models/guardian_ownership.dart';
import 'package:boussole/repositories/guardian_repository.dart';
import 'package:boussole/services/guardian_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('économie des Compagnons', () {
    test('applique les prix officiels', () {
      expect(_guardian(GuardianId.wave).price, 0);
      expect(_guardian(GuardianId.crystal).price, 10);
      expect(_guardian(GuardianId.pixel).price, 10);
      expect(_guardian(GuardianId.pyro).price, 15);
      expect(_guardian(GuardianId.gear).price, 15);
    });

    test('Wave est toujours possédé', () {
      final state = GuardianOwnership.fromChildData(const {});
      expect(state.selectedId, GuardianId.wave);
      expect(state.owns(GuardianId.wave), isTrue);
      expect(state.owns(GuardianId.crystal), isFalse);
    });

    test('préserve le Compagnon sélectionné d’un ancien profil', () {
      final state = GuardianOwnership.fromChildData(const {
        'guardianId': 'pyro',
      });
      expect(state.selectedId, GuardianId.pyro);
      expect(state.owns(GuardianId.wave), isTrue);
      expect(state.owns(GuardianId.pyro), isTrue);
      expect(state.owns(GuardianId.crystal), isFalse);
    });

    test('relit les Compagnons achetés persistés', () {
      final state = GuardianOwnership.fromChildData(const {
        'guardianId': 'wave',
        'ownedGuardianIds': ['wave', 'crystal', 'pixel'],
      });
      expect(state.owns(GuardianId.crystal), isTrue);
      expect(state.owns(GuardianId.pixel), isTrue);
      expect(state.owns(GuardianId.gear), isFalse);
    });

    test(
      'achète une fois, débite exactement et conserve la propriété',
      () async {
        final service = _FakeGuardianService(balance: 20);
        final repository = GuardianRepository(service: service);
        final crystal = _guardian(GuardianId.crystal);

        expect(
          await repository.purchaseGuardian(
            familyId: 'family',
            childId: 'child',
            guardian: crystal,
          ),
          GuardianPurchaseResult.purchased,
        );
        expect(service.balance, 10);
        expect(service.ownership.owns(GuardianId.crystal), isTrue);
        expect(
          await repository.purchaseGuardian(
            familyId: 'family',
            childId: 'child',
            guardian: crystal,
          ),
          GuardianPurchaseResult.alreadyOwned,
        );
        expect(service.balance, 10);
      },
    );

    test('refuse un achat sans solde et une sélection non possédée', () async {
      final service = _FakeGuardianService(balance: 9);
      final repository = GuardianRepository(service: service);
      expect(
        await repository.purchaseGuardian(
          familyId: 'family',
          childId: 'child',
          guardian: _guardian(GuardianId.crystal),
        ),
        GuardianPurchaseResult.insufficientBalance,
      );
      expect(service.balance, 9);
      expect(
        await repository.selectGuardian(
          familyId: 'family',
          childId: 'child',
          guardian: _guardian(GuardianId.pyro),
        ),
        GuardianSelectionResult.notOwned,
      );
    });

    test('le changement entre Compagnons possédés est gratuit', () async {
      final service = _FakeGuardianService(
        balance: 12,
        owned: const {GuardianId.wave, GuardianId.pixel},
      );
      final repository = GuardianRepository(service: service);
      expect(
        await repository.selectGuardian(
          familyId: 'family',
          childId: 'child',
          guardian: _guardian(GuardianId.pixel),
        ),
        GuardianSelectionResult.selected,
      );
      expect(service.balance, 12);
      expect(service.ownership.selectedId, GuardianId.pixel);
    });
  });
}

GuardianModel _guardian(GuardianId id) =>
    GuardianModel.all.firstWhere((guardian) => guardian.id == id);

class _FakeGuardianService implements GuardianService {
  _FakeGuardianService({
    required this.balance,
    Set<GuardianId> owned = const {GuardianId.wave},
  }) : ownership = GuardianOwnership(
         selectedId: GuardianId.wave,
         ownedIds: {...owned},
       );

  int balance;
  GuardianOwnership ownership;

  @override
  Future<GuardianOwnership> getOwnership({
    required String familyId,
    required String childId,
  }) async => ownership;

  @override
  Future<GuardianPurchaseResult> purchaseGuardian({
    required String familyId,
    required String childId,
    required GuardianModel guardian,
    bool selectAfterPurchase = true,
  }) async {
    if (ownership.owns(guardian.id)) return GuardianPurchaseResult.alreadyOwned;
    if (balance < guardian.price) {
      return GuardianPurchaseResult.insufficientBalance;
    }
    balance -= guardian.price;
    ownership = GuardianOwnership(
      selectedId: selectAfterPurchase ? guardian.id : ownership.selectedId,
      ownedIds: {...ownership.ownedIds, guardian.id},
    );
    return GuardianPurchaseResult.purchased;
  }

  @override
  Future<GuardianSelectionResult> selectGuardian({
    required String familyId,
    required String childId,
    required String guardianId,
  }) async {
    final guardian = _guardian(GuardianModel.fromStorageId(guardianId).id);
    if (!ownership.owns(guardian.id)) return GuardianSelectionResult.notOwned;
    ownership = GuardianOwnership(
      selectedId: guardian.id,
      ownedIds: ownership.ownedIds,
    );
    return GuardianSelectionResult.selected;
  }
}
