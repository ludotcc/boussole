import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/child_model.dart';
import '../providers/family_provider.dart';
import '../providers/session_provider.dart';

final childrenProvider = FutureProvider<List<ChildModel>>((ref) async {
  final session = ref.watch(sessionProvider);

  if (session == null) {
    return [];
  }

  return ref
      .read(familyRepositoryProvider)
      .getChildren(familyId: session.familyId);
});
