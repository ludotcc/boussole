import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shared_moment.dart';
import 'mission_provider.dart';
import 'session_provider.dart';

final sharedMomentsProvider = FutureProvider.family<List<SharedMoment>, String>(
  (ref, childId) async {
    final session = ref.watch(sessionProvider);
    if (session == null || childId.isEmpty) throw StateError('Enfant invalide');
    return ref
        .read(missionRepositoryProvider)
        .getSharedMoments(familyId: session.familyId, childId: childId);
  },
);
