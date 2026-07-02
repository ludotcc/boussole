import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/family_repository.dart';

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository();
});
