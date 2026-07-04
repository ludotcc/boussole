import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';

abstract class FamilyActionNotifier extends StateNotifier<AsyncValue<void>> {
  FamilyActionNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;

  String? requireFamilyId() {
    final session = ref.read(sessionProvider);

    if (session == null || session.familyId.isEmpty) {
      state = AsyncError(Exception("Session introuvable."), StackTrace.current);
      return null;
    }

    return session.familyId;
  }

  Future<void> runFamilyAction(
    Future<void> Function(String familyId) action,
  ) async {
    final familyId = requireFamilyId();

    if (familyId == null) {
      return;
    }

    state = const AsyncLoading();

    try {
      await action(familyId);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
