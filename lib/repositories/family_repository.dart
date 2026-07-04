import '../models/child_model.dart';
import '../models/day_exception_model.dart';
import '../models/day_type_model.dart';
import '../models/family_model.dart';
import '../models/moment_model.dart';
import '../models/parent_model.dart';
import '../models/routine_model.dart';
import '../models/session_model.dart';
import '../models/step_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class FamilyRepository {
  FamilyRepository({
    AuthService? authService,
    FirestoreService? firestoreService,
  }) : _authService = authService ?? AuthService(),
       _firestoreService = firestoreService ?? FirestoreService();

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<SessionModel> createFamily({
    required String familyName,
    required String parentName,
    required String email,
    required String password,
  }) async {
    final credential = await _authService.createAccount(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception("Impossible de créer le compte.");
    }

    final familyId = await _firestoreService.createFamily(
      FamilyModel(
        id: '',
        name: familyName,
        createdBy: user.uid,
        createdAt: DateTime.now(),
      ),
    );

    await _firestoreService.createParent(
      ParentModel(
        uid: user.uid,
        familyId: familyId,
        firstName: parentName,
        email: email,
        avatar: '',
        createdAt: DateTime.now(),
      ),
    );

    await _firestoreService.createUserIndex(uid: user.uid, familyId: familyId);

    return SessionModel(
      userId: user.uid,
      familyId: familyId,
      firstName: parentName,
      email: email,
      avatar: '',
      role: UserRole.parent,
    );
  }

  Future<SessionModel> signIn({
    required String email,
    required String password,
  }) async {
    await _authService.signIn(email: email, password: password);

    final session = await restoreSession();

    if (session == null) {
      throw Exception(
        "Impossible de restaurer les informations de votre famille.",
      );
    }

    return session;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> saveParentAvatar({
    required String familyId,
    required String parentId,
    required String avatarId,
  }) {
    return _firestoreService.updateParentAvatar(
      familyId: familyId,
      parentId: parentId,
      avatarId: avatarId,
    );
  }

  // ---------------------------------------------------------------------------
  // Enfants
  // ---------------------------------------------------------------------------

  Future<void> createChild(ChildModel child) {
    return _firestoreService.createChild(child);
  }

  Future<void> createChildProfile({
    required String familyId,
    required String firstName,
    required int age,
    required String avatar,
  }) {
    final child = ChildModel(
      id: _firestoreService.generateChildId(familyId),
      familyId: familyId,
      firstName: firstName,
      avatar: avatar,
      age: age,
      createdAt: DateTime.now(),
    );

    return _firestoreService.createChild(child);
  }

  Future<List<ChildModel>> getChildren({required String familyId}) {
    return _firestoreService.getChildren(familyId: familyId);
  }

  // ---------------------------------------------------------------------------
  // Journées Types
  // ---------------------------------------------------------------------------

  Future<void> createDayType(DayTypeModel dayType) {
    return _firestoreService.createDayType(dayType);
  }

  Future<List<DayTypeModel>> getDayTypes({required String familyId}) {
    return _firestoreService.getDayTypes(familyId: familyId);
  }

  // ---------------------------------------------------------------------------
  // Exceptions de journées
  // ---------------------------------------------------------------------------

  Future<List<DayExceptionModel>> getDayExceptions({required String familyId}) {
    return _firestoreService.getDayExceptions(familyId: familyId);
  }

  Future<DayExceptionModel?> getDayExceptionForDate({
    required String familyId,
    required DateTime date,
  }) {
    return _firestoreService.getDayExceptionByDate(
      familyId: familyId,
      dateKey: _dateKey(date),
    );
  }

  Future<void> saveDayException({
    required String familyId,
    required DateTime date,
    required String dayTypeId,
    required List<String> momentIds,
  }) async {
    final existingException = await getDayExceptionForDate(
      familyId: familyId,
      date: date,
    );
    final now = DateTime.now();

    if (existingException == null) {
      final dayException = DayExceptionModel(
        id: _firestoreService.generateDayExceptionId(familyId),
        familyId: familyId,
        dateKey: _dateKey(date),
        dayTypeId: dayTypeId,
        momentIds: momentIds,
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      return _firestoreService.createDayException(dayException);
    }

    return _firestoreService.updateDayException(
      existingException.copyWith(
        dayTypeId: dayTypeId,
        momentIds: momentIds,
        active: true,
        updatedAt: now,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Moments
  // ---------------------------------------------------------------------------

  Future<void> createMoment({
    required String familyId,
    required MomentModel moment,
  }) {
    return _firestoreService.createMoment(familyId: familyId, moment: moment);
  }

  Future<void> createDefaultMoment({
    required String familyId,
    required String type,
  }) async {
    final dayType = await _getOrCreateDefaultDayType(familyId: familyId);
    final position = dayType.momentIds.length;

    final moment = _buildDefaultMoment(
      familyId: familyId,
      type: type,
      position: position,
    );

    await _firestoreService.createMoment(familyId: familyId, moment: moment);

    await _firestoreService.updateDayType(
      dayType.copyWith(momentIds: [...dayType.momentIds, moment.id]),
    );
  }

  Future<List<MomentModel>> getMoments({required String familyId}) async {
    final dayType = await _getOrCreateDefaultDayType(familyId: familyId);
    final moments = await _firestoreService.getMoments(familyId: familyId);

    if (dayType.momentIds.isEmpty) {
      return moments;
    }

    final momentsById = {for (final moment in moments) moment.id: moment};

    return [
      for (final momentId in dayType.momentIds)
        if (momentsById[momentId] != null) momentsById[momentId]!,
    ];
  }

  Future<void> updateMoment({
    required String familyId,
    required MomentModel moment,
  }) {
    return _firestoreService.updateMoment(familyId: familyId, moment: moment);
  }

  Future<void> duplicateMoment({
    required String familyId,
    required MomentModel moment,
  }) async {
    final dayType = await _getOrCreateDefaultDayType(familyId: familyId);
    final existingMoments = await getMoments(familyId: familyId);
    final insertionIndex = _nextIndexAfter(
      ids: existingMoments.map((existingMoment) => existingMoment.id).toList(),
      sourceId: moment.id,
    );
    final now = DateTime.now();

    final duplicatedMoment = MomentModel(
      id: _firestoreService.generateMomentId(familyId),
      familyId: familyId,
      name: _copyName(moment.name),
      type: moment.type,
      iconKey: moment.iconKey,
      colorKey: moment.colorKey,
      position: insertionIndex,
      hasRoutine: moment.hasRoutine,
      active: moment.active,
      createdAt: now,
    );

    await _firestoreService.createMoment(
      familyId: familyId,
      moment: duplicatedMoment,
    );

    final copiedRoutines = await _duplicateRoutinesForMoment(
      familyId: familyId,
      sourceMomentId: moment.id,
      targetMomentId: duplicatedMoment.id,
    );

    final savedMoment = copiedRoutines.isEmpty
        ? duplicatedMoment
        : duplicatedMoment.copyWith(
            hasRoutine: true,
            routineId: copiedRoutines.first.id,
          );

    if (copiedRoutines.isNotEmpty) {
      await _firestoreService.updateMoment(
        familyId: familyId,
        moment: savedMoment,
      );
    }

    final reorderedMoments = [...existingMoments]
      ..insert(insertionIndex, savedMoment);

    await _firestoreService.updateMomentPositions(
      familyId: familyId,
      positionsByMomentId: _positionsById(reorderedMoments),
    );

    final reorderedMomentIds = reorderedMoments
        .map((existingMoment) => existingMoment.id)
        .toList();

    await _firestoreService.updateDayType(
      dayType.copyWith(momentIds: reorderedMomentIds),
    );
  }

  Future<void> reorderMoments({
    required String familyId,
    required List<MomentModel> moments,
  }) async {
    final positionsByMomentId = <String, int>{
      for (var index = 0; index < moments.length; index++)
        moments[index].id: index,
    };

    await _firestoreService.updateMomentPositions(
      familyId: familyId,
      positionsByMomentId: positionsByMomentId,
    );

    final dayType = await _getOrCreateDefaultDayType(familyId: familyId);

    await _firestoreService.updateDayType(
      dayType.copyWith(momentIds: moments.map((moment) => moment.id).toList()),
    );
  }

  Future<void> deleteMoment({
    required String familyId,
    required String momentId,
  }) async {
    await _firestoreService.deleteMoment(
      familyId: familyId,
      momentId: momentId,
    );

    final dayType = await _getOrCreateDefaultDayType(familyId: familyId);
    final momentIds = dayType.momentIds
        .where((existingMomentId) => existingMomentId != momentId)
        .toList();

    await _firestoreService.updateDayType(
      dayType.copyWith(momentIds: momentIds),
    );
  }

  // ---------------------------------------------------------------------------
  // Routines
  // ---------------------------------------------------------------------------

  Future<RoutineModel?> getRoutineForMoment({
    required String familyId,
    required MomentModel moment,
  }) {
    final routineId = moment.routineId;

    if (routineId == null || routineId.isEmpty) {
      return Future.value(null);
    }

    return _firestoreService.getRoutine(
      familyId: familyId,
      routineId: routineId,
    );
  }

  Future<List<RoutineModel>> getRoutinesForMoment({
    required String familyId,
    required MomentModel moment,
  }) {
    return _firestoreService.getRoutinesForMoment(
      familyId: familyId,
      momentId: moment.id,
    );
  }

  Future<void> createRoutineForMoment({
    required String familyId,
    required MomentModel moment,
    required String name,
    required String icon,
  }) async {
    final routineId = _firestoreService.generateRoutineId(familyId);
    final order = await _firestoreService.getNextRoutineOrder(
      familyId: familyId,
      momentId: moment.id,
    );

    final routine = RoutineModel(
      id: routineId,
      name: name,
      icon: icon,
      momentId: moment.id,
      order: order,
      active: true,
      createdAt: DateTime.now(),
    );

    return _firestoreService.createRoutine(
      familyId: familyId,
      routine: routine,
    );
  }

  Future<void> updateRoutine({
    required String familyId,
    required RoutineModel routine,
  }) {
    return _firestoreService.updateRoutine(
      familyId: familyId,
      routine: routine,
    );
  }

  Future<void> deleteRoutine({
    required String familyId,
    required String routineId,
  }) {
    return _firestoreService.deleteRoutine(
      familyId: familyId,
      routineId: routineId,
    );
  }

  Future<void> duplicateRoutine({
    required String familyId,
    required RoutineModel routine,
  }) async {
    final existingRoutines = await _firestoreService.getRoutinesForMoment(
      familyId: familyId,
      momentId: routine.momentId,
    );
    final insertionIndex = _nextIndexAfter(
      ids: existingRoutines
          .map((existingRoutine) => existingRoutine.id)
          .toList(),
      sourceId: routine.id,
    );
    final duplicatedRoutine = await _duplicateRoutineWithSteps(
      familyId: familyId,
      routine: routine,
      targetMomentId: routine.momentId,
      order: insertionIndex,
    );

    final reorderedRoutines = [...existingRoutines]
      ..insert(insertionIndex, duplicatedRoutine);

    await _firestoreService.updateRoutineOrders(
      familyId: familyId,
      ordersByRoutineId: _ordersById(reorderedRoutines),
    );
  }

  Future<void> reorderRoutines({
    required String familyId,
    required List<RoutineModel> routines,
  }) {
    final ordersByRoutineId = <String, int>{
      for (var index = 0; index < routines.length; index++)
        routines[index].id: index,
    };

    return _firestoreService.updateRoutineOrders(
      familyId: familyId,
      ordersByRoutineId: ordersByRoutineId,
    );
  }

  Future<DayTypeModel> _getOrCreateDefaultDayType({
    required String familyId,
  }) async {
    final existingDayType = await _firestoreService.getDayTypeByType(
      familyId: familyId,
      type: 'default',
    );

    if (existingDayType != null) {
      return existingDayType;
    }

    final dayType = DayTypeModel(
      id: _firestoreService.generateDayTypeId(familyId),
      familyId: familyId,
      name: 'Journée',
      type: 'default',
      order: 0,
      momentIds: const [],
      active: true,
    );

    await _firestoreService.createDayType(dayType);

    return dayType;
  }

  // ---------------------------------------------------------------------------
  // Étapes
  // ---------------------------------------------------------------------------

  Future<List<StepModel>> getStepsForRoutine({
    required String familyId,
    required RoutineModel routine,
  }) {
    return _firestoreService.getSteps(
      familyId: familyId,
      routineId: routine.id,
    );
  }

  Future<void> createStepForRoutine({
    required String familyId,
    required RoutineModel routine,
    required String title,
    required String description,
    required String icon,
  }) async {
    final stepId = _firestoreService.generateStepId(
      familyId: familyId,
      routineId: routine.id,
    );
    final order = await _firestoreService.getNextStepOrder(
      familyId: familyId,
      routineId: routine.id,
    );

    final step = StepModel(
      id: stepId,
      routineId: routine.id,
      title: title,
      description: description,
      icon: icon,
      order: order,
      active: true,
      createdAt: DateTime.now(),
    );

    return _firestoreService.createStep(
      familyId: familyId,
      routineId: routine.id,
      step: step,
    );
  }

  Future<void> updateStep({required String familyId, required StepModel step}) {
    return _firestoreService.updateStep(
      familyId: familyId,
      routineId: step.routineId,
      step: step,
    );
  }

  Future<void> deleteStep({
    required String familyId,
    required String routineId,
    required String stepId,
  }) {
    return _firestoreService.deleteStep(
      familyId: familyId,
      routineId: routineId,
      stepId: stepId,
    );
  }

  Future<void> reorderSteps({
    required String familyId,
    required RoutineModel routine,
    required List<StepModel> steps,
  }) {
    final ordersByStepId = <String, int>{
      for (var index = 0; index < steps.length; index++) steps[index].id: index,
    };

    return _firestoreService.updateStepOrders(
      familyId: familyId,
      routineId: routine.id,
      ordersByStepId: ordersByStepId,
    );
  }

  Future<List<RoutineModel>> _duplicateRoutinesForMoment({
    required String familyId,
    required String sourceMomentId,
    required String targetMomentId,
  }) async {
    final routines = await _firestoreService.getRoutinesForMoment(
      familyId: familyId,
      momentId: sourceMomentId,
    );
    final copiedRoutines = <RoutineModel>[];

    for (var index = 0; index < routines.length; index++) {
      final copiedRoutine = await _duplicateRoutineWithSteps(
        familyId: familyId,
        routine: routines[index],
        targetMomentId: targetMomentId,
        order: index,
      );

      copiedRoutines.add(copiedRoutine);
    }

    return copiedRoutines;
  }

  Future<RoutineModel> _duplicateRoutineWithSteps({
    required String familyId,
    required RoutineModel routine,
    required String targetMomentId,
    required int order,
  }) async {
    final duplicatedRoutine = RoutineModel(
      id: _firestoreService.generateRoutineId(familyId),
      name: _copyName(routine.name),
      icon: routine.icon,
      momentId: targetMomentId,
      order: order,
      active: routine.active,
      createdAt: DateTime.now(),
    );

    await _firestoreService.createRoutine(
      familyId: familyId,
      routine: duplicatedRoutine,
    );

    final steps = await _firestoreService.getSteps(
      familyId: familyId,
      routineId: routine.id,
    );

    for (var index = 0; index < steps.length; index++) {
      final step = steps[index];
      final duplicatedStep = StepModel(
        id: _firestoreService.generateStepId(
          familyId: familyId,
          routineId: duplicatedRoutine.id,
        ),
        routineId: duplicatedRoutine.id,
        title: step.title,
        description: step.description,
        icon: step.icon,
        order: index,
        active: step.active,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createStep(
        familyId: familyId,
        routineId: duplicatedRoutine.id,
        step: duplicatedStep,
      );
    }

    return duplicatedRoutine;
  }

  int _nextIndexAfter({required List<String> ids, required String sourceId}) {
    final sourceIndex = ids.indexOf(sourceId);

    if (sourceIndex == -1) {
      return ids.length;
    }

    return sourceIndex + 1;
  }

  Map<String, int> _positionsById(List<MomentModel> moments) {
    return {
      for (var index = 0; index < moments.length; index++)
        moments[index].id: index,
    };
  }

  Map<String, int> _ordersById(List<RoutineModel> routines) {
    return {
      for (var index = 0; index < routines.length; index++)
        routines[index].id: index,
    };
  }

  String _copyName(String name) {
    return '$name (copie)';
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  MomentModel _buildDefaultMoment({
    required String familyId,
    required String type,
    required int position,
  }) {
    final id = _firestoreService.generateMomentId(familyId);
    final now = DateTime.now();

    switch (type) {
      case 'routine_morning':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Rituel du matin',
          type: 'routine',
          iconKey: 'routineMorning',
          colorKey: 'momentMorning',
          position: position,
          hasRoutine: true,
          active: true,
          createdAt: now,
        );
      case 'meal':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Repas',
          type: 'meal',
          iconKey: 'breakfast',
          colorKey: 'momentMeal',
          position: position,
          hasRoutine: false,
          active: true,
          createdAt: now,
        );
      case 'school':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Devoirs',
          type: 'school',
          iconKey: 'homework',
          colorKey: 'momentSchool',
          position: position,
          hasRoutine: false,
          active: true,
          createdAt: now,
        );
      case 'leisure':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Temps libre',
          type: 'leisure',
          iconKey: 'videoGames',
          colorKey: 'momentLeisure',
          position: position,
          hasRoutine: false,
          active: true,
          createdAt: now,
        );
      case 'routine_evening':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Rituel du soir',
          type: 'routine',
          iconKey: 'routineEvening',
          colorKey: 'momentEvening',
          position: position,
          hasRoutine: true,
          active: true,
          createdAt: now,
        );
      case 'bike':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Vélo',
          type: 'leisure',
          iconKey: 'bike',
          colorKey: 'momentHygiene',
          position: position,
          hasRoutine: false,
          active: true,
          createdAt: now,
        );
      default:
        throw Exception('Type de moment inconnu.');
    }
  }

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  Future<SessionModel?> restoreSession() async {
    final user = _authService.currentUser;

    if (user == null) {
      return null;
    }

    final familyId = await _firestoreService.getFamilyIdFromUser(user.uid);

    if (familyId == null) {
      return null;
    }

    final parent = await _firestoreService.getParent(
      familyId: familyId,
      parentId: user.uid,
    );

    if (parent == null) {
      return null;
    }

    return SessionModel(
      userId: parent.uid,
      familyId: parent.familyId,
      firstName: parent.firstName,
      email: parent.email,
      avatar: parent.avatar,
      role: parent.role,
    );
  }
}
