import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/day_type_model.dart';
import 'family_provider.dart';
import 'session_provider.dart';

final familyPlanningsProvider = FutureProvider<List<DayTypeModel>>((ref) async {
  final session = ref.watch(sessionProvider);

  if (session == null) {
    return [];
  }

  final repository = ref.watch(familyRepositoryProvider);

  return repository.getFamilyPlannings(familyId: session.familyId);
});

final dayTypesProvider = familyPlanningsProvider;
