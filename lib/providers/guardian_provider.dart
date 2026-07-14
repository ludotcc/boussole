import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/guardian_model.dart';
import '../repositories/guardian_repository.dart';
import 'session_provider.dart';

final guardianRepositoryProvider = Provider<GuardianRepository>(
  (_) => GuardianRepository(),
);

final childGuardianProvider = FutureProvider.family<GuardianModel, String>((
  ref,
  childId,
) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return GuardianModel.all.first;
  return ref
      .read(guardianRepositoryProvider)
      .getGuardian(familyId: session.familyId, childId: childId);
});

class GuardianSelectionNotifier extends StateNotifier<AsyncValue<void>> {
  GuardianSelectionNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> select({
    required String childId,
    required GuardianModel guardian,
  }) async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(guardianRepositoryProvider)
          .selectGuardian(
            familyId: session.familyId,
            childId: childId,
            guardian: guardian,
          );
      ref.invalidate(childGuardianProvider(childId));
    });
  }
}

final guardianSelectionProvider =
    StateNotifierProvider<GuardianSelectionNotifier, AsyncValue<void>>(
      GuardianSelectionNotifier.new,
    );
