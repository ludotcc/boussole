import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/school_academy.dart';
import '../services/academy_service.dart';

final academyServiceProvider = Provider<AcademyService>((ref) {
  return AcademyService();
});

final schoolAcademiesProvider = FutureProvider<List<SchoolAcademy>>((ref) {
  return ref.watch(academyServiceProvider).getAcademies();
});
