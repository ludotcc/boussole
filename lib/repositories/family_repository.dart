import '../core/constants/moment_presets.dart';
import '../models/child_day_item_model.dart';
import '../models/child_model.dart';
import '../models/child_companion_profile.dart';
import '../models/child_day_progress_model.dart';
import '../models/day_exception_model.dart';
import '../models/day_type_model.dart';
import '../models/family_event_model.dart';
import '../models/family_member_model.dart';
import '../models/family_model.dart';
import '../models/moment_model.dart';
import '../models/parent_model.dart';
import '../models/planning_day_kind.dart';
import '../models/routine_model.dart';
import '../models/school_academy.dart';
import '../models/session_model.dart';
import '../models/step_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'planning_day_resolver.dart';

class FamilyRepository {
  FamilyRepository({
    AuthService? authService,
    FirestoreService? firestoreService,
  }) : _authService = authService ?? AuthService(),
       _firestoreService = firestoreService ?? FirestoreService();

  final AuthService _authService;
  final FirestoreService _firestoreService;
  final PlanningDayResolver _planningDayResolver = PlanningDayResolver();

  Future<SessionModel> createFamily({
    required String familyName,
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

    await _firestoreService.createUserIndex(uid: user.uid, familyId: familyId);

    return SessionModel(
      userId: user.uid,
      familyId: familyId,
      firstName: familyName,
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

  Future<void> createAdultProfile({
    required String familyId,
    required String firstName,
    required int age,
    required String profileType,
    required String avatar,
  }) {
    final parent = ParentModel(
      uid: _firestoreService.generateMemberId(familyId),
      familyId: familyId,
      firstName: firstName,
      email: '',
      avatar: avatar,
      age: age,
      profileType: profileType,
      createdAt: DateTime.now(),
    );

    return _firestoreService.createParent(parent);
  }

  Future<List<FamilyMemberModel>> getFamilyMembers({
    required String familyId,
  }) async {
    final adults = await getAdultProfiles(familyId: familyId);
    final children = await getChildren(familyId: familyId);
    final members = [
      ...adults.map(FamilyMemberModel.fromParent),
      ...children.map(FamilyMemberModel.fromChild),
    ];

    members.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return members;
  }

  Future<void> updateFamilyMember({
    required FamilyMemberModel member,
    required String firstName,
    required int age,
    required String avatar,
    required String profileType,
  }) async {
    if (member.isAdult) {
      return _firestoreService.updateParent(
        ParentModel(
          uid: member.id,
          familyId: member.familyId,
          firstName: firstName,
          email: '',
          avatar: avatar,
          age: age,
          profileType: profileType,
          createdAt: member.createdAt,
        ),
      );
    }

    final existingChild = await _firestoreService.getChild(
      familyId: member.familyId,
      childId: member.id,
    );

    return _firestoreService.updateChild(
      ChildModel(
        id: member.id,
        familyId: member.familyId,
        firstName: firstName,
        avatar: avatar,
        age: age,
        birthDate: existingChild?.birthDate,
        companionProfile:
            existingChild?.companionProfile ?? const ChildCompanionProfile(),
        profileType: profileType,
        academyId:
            existingChild?.academyId ??
            member.academyId ??
            defaultSchoolAcademyId,
        weeklyRhythmByWeekday:
            existingChild?.weeklyRhythmByWeekday ??
            ChildModel.weeklyRhythmFromMap(null),
        createdAt: member.createdAt,
      ),
    );
  }

  Future<void> deleteFamilyMember({required FamilyMemberModel member}) {
    if (member.isAdult) {
      return _firestoreService.deleteParent(
        familyId: member.familyId,
        parentId: member.id,
      );
    }

    return _firestoreService.deleteChild(
      familyId: member.familyId,
      childId: member.id,
    );
  }

  Future<void> updateFamilySettings({
    required String familyId,
    required String familyName,
    required String email,
    required String password,
  }) async {
    if (familyName.trim().isEmpty) {
      throw Exception("Merci d'indiquer un nom de famille.");
    }

    await _firestoreService.updateFamilyName(
      familyId: familyId,
      name: familyName.trim(),
    );

    if (email.trim().isNotEmpty) {
      await _authService.updateEmail(email);
    }

    if (password.isNotEmpty) {
      await _authService.updatePassword(password);
    }
  }

  // ---------------------------------------------------------------------------
  // Agenda familial
  // ---------------------------------------------------------------------------

  Future<List<FamilyEventModel>> getEvents({required String familyId}) async {
    final events = await _firestoreService.getEvents(familyId: familyId);

    events.sort(_compareEvents);

    return events;
  }

  Future<List<FamilyEventModel>> getEventsForChildOnDate({
    required String familyId,
    required String childId,
    required DateTime date,
  }) async {
    final day = _dateOnly(date);
    final events = await getEvents(familyId: familyId);

    return events.where((event) {
      return _dateOnly(event.date) == day && event.memberIds.contains(childId);
    }).toList();
  }

  Future<List<ChildDayItemModel>> getChildDayItemsForDate({
    required String familyId,
    required String childId,
    required DateTime date,
  }) async {
    final moments = await getMomentsForChildDate(
      familyId: familyId,
      childId: childId,
      date: date,
    );
    final events = await getEventsForChildOnDate(
      familyId: familyId,
      childId: childId,
      date: date,
    );
    final items = <ChildDayItemModel>[
      for (final moment in moments)
        ChildDayItemModel(
          id: moment.id,
          itemType: ChildDayItemType.moment,
          title: moment.name,
          iconKey: moment.iconKey,
          orderMinutes: moment.orderMinutes,
          isSensitive: false,
          childTimeDisplayType: _canUseMomentTimeOptionsForMoment(moment)
              ? moment.childTimeDisplayType
              : 'none',
          timerMinutes: _canUseMomentTimeOptionsForMoment(moment)
              ? moment.timerMinutes
              : null,
          maxDurationMinutes: _canUseMomentTimeOptionsForMoment(moment)
              ? moment.maxDurationMinutes
              : null,
          moment: moment,
        ),
      for (final event in events)
        ChildDayItemModel(
          id: _eventProgressId(event.id),
          itemType: ChildDayItemType.event,
          title: event.title,
          iconKey: _eventIconKey(event),
          colorKey: event.isSensitiveMoment
              ? 'eventSensitive'
              : _eventColorKey(event.type),
          orderMinutes: _eventOrderMinutes(event),
          isSensitive: event.isSensitiveMoment,
          childTimeDisplayType: event.childTimeDisplayType,
          timerMinutes: event.timerMinutes,
          maxDurationMinutes: event.maxDurationMinutes,
          endTime: event.endTime,
          event: event,
        ),
    ];

    items.sort(
      (a, b) => _compareScheduleOrder(
        aOrderMinutes: a.orderMinutes,
        bOrderMinutes: b.orderMinutes,
        aTitle: a.title,
        bTitle: b.title,
      ),
    );

    return items;
  }

  Future<PlanningDayKind> getChildPlanningDayKindForDate({
    required String familyId,
    required String childId,
    required DateTime date,
  }) async {
    final child = await _firestoreService.getChild(
      familyId: familyId,
      childId: childId,
    );

    return _planningDayResolver.resolve(date: date, child: child);
  }

  Stream<List<FamilyEventModel>> watchEvents({required String familyId}) {
    return _firestoreService.watchEvents(familyId: familyId);
  }

  Future<void> createEvent({
    required String familyId,
    required String title,
    required String? description,
    required String type,
    required DateTime date,
    required String? time,
    required bool isAllDay,
    required bool isSensitiveMoment,
    required List<String> memberIds,
    required String recurrenceType,
    required String childTimeDisplayType,
    required int? timerMinutes,
    required int? maxDurationMinutes,
  }) {
    final now = DateTime.now();
    final event = FamilyEventModel(
      id: _firestoreService.generateEventId(familyId),
      familyId: familyId,
      title: title.trim(),
      description: _cleanOptional(description),
      type: type,
      date: _dateOnly(date),
      time: isAllDay ? null : _cleanOptional(time),
      isAllDay: isAllDay,
      isSensitiveMoment: isSensitiveMoment,
      memberIds: memberIds,
      recurrenceType: recurrenceType,
      childTimeDisplayType: childTimeDisplayType,
      timerMinutes: childTimeDisplayType == 'timer' ? timerMinutes : null,
      maxDurationMinutes: childTimeDisplayType == 'maxDuration'
          ? maxDurationMinutes
          : null,
      endTime: null,
      createdAt: now,
      updatedAt: now,
    );

    _validateEvent(event);

    return _firestoreService.createEvent(event);
  }

  Future<void> updateEvent(FamilyEventModel event) {
    final updatedEvent = event.copyWith(
      title: event.title.trim(),
      description: _cleanOptional(event.description),
      date: _dateOnly(event.date),
      time: event.isAllDay ? null : _cleanOptional(event.time),
      childTimeDisplayType: event.childTimeDisplayType,
      timerMinutes: event.childTimeDisplayType == 'timer'
          ? event.timerMinutes
          : null,
      maxDurationMinutes: event.childTimeDisplayType == 'maxDuration'
          ? event.maxDurationMinutes
          : null,
      endTime: null,
      updatedAt: DateTime.now(),
    );

    _validateEvent(updatedEvent);

    return _firestoreService.updateEvent(updatedEvent);
  }

  Future<void> deleteEvent({
    required String familyId,
    required String eventId,
  }) {
    return _firestoreService.deleteEvent(familyId: familyId, eventId: eventId);
  }

  // ---------------------------------------------------------------------------
  // Enfants
  // ---------------------------------------------------------------------------

  Future<void> createChild(ChildModel child) async {
    await _firestoreService.createChild(child);

    if (_canUseChildSpace(child)) {
      await _initializeChildPlannings(child);
    }
  }

  Future<void> createChildProfile({
    required String familyId,
    required String firstName,
    required int age,
    DateTime? birthDate,
    required String avatar,
    String profileType = 'child',
    String? academyId,
    Map<int, String>? weeklyRhythmByWeekday,
  }) {
    final child = ChildModel(
      id: _firestoreService.generateChildId(familyId),
      familyId: familyId,
      firstName: firstName,
      avatar: avatar,
      age: age,
      birthDate: birthDate,
      profileType: profileType,
      academyId: academyId ?? defaultSchoolAcademyId,
      weeklyRhythmByWeekday:
          weeklyRhythmByWeekday ?? ChildModel.weeklyRhythmFromMap(null),
      createdAt: DateTime.now(),
    );

    return createChild(child);
  }

  Future<List<ChildModel>> getChildren({required String familyId}) {
    return _firestoreService.getChildren(familyId: familyId);
  }

  Future<List<ChildModel>> getChildProfiles({required String familyId}) async {
    final children = await getChildren(familyId: familyId);

    return children.where(_canUseChildSpace).toList();
  }

  Future<void> updateChildWeeklyRhythm({
    required String familyId,
    required String childId,
    required Map<int, String> weeklyRhythmByWeekday,
    String? academyId,
  }) async {
    final child = await _firestoreService.getChild(
      familyId: familyId,
      childId: childId,
    );

    if (child == null) {
      return;
    }

    await _firestoreService.updateChild(
      ChildModel(
        id: child.id,
        familyId: child.familyId,
        firstName: child.firstName,
        avatar: child.avatar,
        age: child.age,
        birthDate: child.birthDate,
        companionProfile: child.companionProfile,
        profileType: child.profileType,
        academyId: academyId ?? child.academyId,
        weeklyRhythmByWeekday: weeklyRhythmByWeekday,
        createdAt: child.createdAt,
      ),
    );
  }

  Future<List<ParentModel>> getAdultProfiles({required String familyId}) {
    return _firestoreService.getAdultProfiles(familyId: familyId);
  }

  Future<FamilyModel?> getFamily({required String familyId}) {
    return _firestoreService.getFamily(familyId: familyId);
  }

  Future<ChildDayProgressModel?> getChildDayProgress({
    required String familyId,
    required String childId,
    required DateTime date,
  }) async {
    if (!await _canUseChildProgress(familyId: familyId, childId: childId)) {
      return null;
    }

    return _firestoreService.getChildDayProgress(
      familyId: familyId,
      childId: childId,
      dateKey: _dateKey(date),
    );
  }

  Future<void> saveChildDayProgress({
    required String familyId,
    required String childId,
    required DateTime date,
    required Map<String, String> momentStatuses,
    required Map<String, DateTime> startedAtByMomentId,
    required Map<String, int> dailyUseCountsByMomentId,
    required List<String> customOrderItemIds,
    required List<String> dismissedMomentIds,
  }) async {
    if (!await _canUseChildProgress(familyId: familyId, childId: childId)) {
      return;
    }

    final dateKey = _dateKey(date);

    return _firestoreService.saveChildDayProgress(
      progress: ChildDayProgressModel(
        id: dateKey,
        familyId: familyId,
        childId: childId,
        dateKey: dateKey,
        momentStatuses: momentStatuses,
        startedAtByMomentId: startedAtByMomentId,
        dailyUseCountsByMomentId: dailyUseCountsByMomentId,
        customOrderItemIds: customOrderItemIds,
        dismissedMomentIds: dismissedMomentIds,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<bool> _canUseChildProgress({
    required String familyId,
    required String childId,
  }) async {
    final children = await getChildren(familyId: familyId);
    final child = children.cast<ChildModel?>().firstWhere(
      (child) => child?.id == childId,
      orElse: () => null,
    );

    return child != null && _canUseChildSpace(child);
  }

  bool _canUseChildSpace(ChildModel child) {
    return child.profileType != 'baby';
  }

  // ---------------------------------------------------------------------------
  // Planning familial
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Exceptions de planning
  // ---------------------------------------------------------------------------

  Future<DayExceptionModel?> getDayExceptionForDate({
    required String familyId,
    required DateTime date,
    String? childId,
  }) {
    return _firestoreService.getDayExceptionByDate(
      familyId: familyId,
      dateKey: _dateKey(date),
      childId: childId,
    );
  }

  Future<void> saveDayException({
    required String familyId,
    required DateTime date,
    required String familyPlanningId,
    required List<String> momentIds,
    String? childId,
  }) async {
    final existingException = await getDayExceptionForDate(
      familyId: familyId,
      date: date,
      childId: childId,
    );
    final now = DateTime.now();

    if (existingException == null) {
      final dayException = DayExceptionModel(
        id: childId == null
            ? _firestoreService.generateDayExceptionId(familyId)
            : '${_dateKey(date)}_$childId',
        familyId: familyId,
        childId: childId,
        dateKey: _dateKey(date),
        dayTypeId: familyPlanningId,
        momentIds: momentIds,
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      return _firestoreService.createDayException(dayException);
    }

    return _firestoreService.updateDayException(
      existingException.copyWith(
        familyPlanningId: familyPlanningId,
        momentIds: momentIds,
        active: true,
        updatedAt: now,
      ),
    );
  }

  Future<void> deleteDayExceptionForDate({
    required String familyId,
    required String childId,
    required DateTime date,
  }) {
    return _firestoreService.deleteDayException(
      familyId: familyId,
      childId: childId,
      dateKey: _dateKey(date),
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
    required String presetKey,
    required String childId,
    PlanningDayKind dayKind = PlanningDayKind.school,
    String? name,
    String? guidanceText,
    String? iconKey,
    int? orderMinutes,
    String childTimeDisplayType = 'none',
    int? timerMinutes,
    int? maxDurationMinutes,
    bool? hasRoutine,
    bool active = true,
    bool isMultiUse = false,
    int? maxDailyUses,
    String scheduleMode = MomentScheduleModes.daily,
    List<int> weekdays = const [],
    DateTime? singleDate,
  }) async {
    final planning = await _getOrCreateChildPlanning(
      familyId: familyId,
      childId: childId,
      dayKind: dayKind,
    );
    final position = planning.momentIds.length;

    final moment = _buildDefaultMoment(
      familyId: familyId,
      presetKey: presetKey,
      position: position,
      orderMinutes: orderMinutes,
      childTimeDisplayType: _canUseMomentTimeOptions(presetKey)
          ? childTimeDisplayType
          : 'none',
      timerMinutes: timerMinutes,
      maxDurationMinutes: maxDurationMinutes,
      isMultiUse: isMultiUse,
      maxDailyUses: isMultiUse ? maxDailyUses : null,
    );
    final configuredMoment = moment.copyWith(
      name: _cleanRequiredOverride(name) ?? moment.name,
      guidanceText: _cleanOptional(guidanceText),
      iconKey: iconKey ?? moment.iconKey,
      hasRoutine: hasRoutine ?? moment.hasRoutine,
      active: active,
      scheduleMode: scheduleMode,
      weekdays: weekdays,
      singleDate: singleDate,
    );
    if (configuredMoment.name.trim().isEmpty) {
      throw Exception("Merci d'indiquer un nom.");
    }
    final sanitizedMoment = _sanitizeMomentSettings(configuredMoment);

    await _firestoreService.createMoment(
      familyId: familyId,
      moment: sanitizedMoment,
    );

    await _firestoreService.updateDayType(
      planning.copyWith(momentIds: [...planning.momentIds, sanitizedMoment.id]),
    );
  }

  Future<List<MomentModel>> getMomentsForChildPlanning({
    required String familyId,
    required String childId,
    PlanningDayKind dayKind = PlanningDayKind.school,
  }) async {
    final planning = await _getChildPlanning(
      familyId: familyId,
      childId: childId,
      dayKind: dayKind,
    );
    final moments = await _firestoreService.getMoments(familyId: familyId);

    if (planning == null) {
      return const [];
    }

    return _momentsFromPlanning(planning: planning, moments: moments)
      ..sort(_compareMomentsBySchedule);
  }

  Future<List<MomentModel>> getMomentsForChildDate({
    required String familyId,
    required String childId,
    required DateTime date,
  }) async {
    final child = await _firestoreService.getChild(
      familyId: familyId,
      childId: childId,
    );
    final dayKind = await _planningDayResolver.resolve(
      date: date,
      child: child,
    );
    final exception = await getDayExceptionForDate(
      familyId: familyId,
      date: date,
      childId: childId,
    );
    if (exception != null) {
      final moments = await _firestoreService.getMoments(familyId: familyId);
      final momentsById = {for (final moment in moments) moment.id: moment};
      return _momentsScheduledForDate(
        moments: [
          for (final momentId in exception.momentIds)
            if (momentsById[momentId] != null) momentsById[momentId]!,
        ],
        date: date,
      );
    }

    final planningMoments = await getMomentsForChildPlanning(
      familyId: familyId,
      childId: childId,
      dayKind: dayKind,
    );
    return _momentsScheduledForDate(moments: planningMoments, date: date);
  }

  Future<void> removeMomentOccurrenceForDate({
    required String familyId,
    required String childId,
    required DateTime date,
    required String momentId,
  }) async {
    final dayKind = await getChildPlanningDayKindForDate(
      familyId: familyId,
      childId: childId,
      date: date,
    );
    final planning = await _getChildPlanning(
      familyId: familyId,
      childId: childId,
      dayKind: dayKind,
    );
    final exception = await getDayExceptionForDate(
      familyId: familyId,
      date: date,
      childId: childId,
    );
    final momentIds = exception == null
        ? [...?planning?.momentIds]
        : [...exception.momentIds];

    momentIds.removeWhere((id) => id == momentId);

    await saveDayException(
      familyId: familyId,
      date: date,
      familyPlanningId: exception?.dayTypeId ?? planning?.id ?? '',
      momentIds: momentIds,
      childId: childId,
    );
  }

  Future<void> updateMoment({
    required String familyId,
    required MomentModel moment,
  }) {
    final updatedMoment = _sanitizeMomentSettings(moment);

    return _firestoreService.updateMoment(
      familyId: familyId,
      moment: updatedMoment,
    );
  }

  Future<void> duplicateMoment({
    required String familyId,
    required MomentModel moment,
    required String childId,
    PlanningDayKind dayKind = PlanningDayKind.school,
  }) async {
    final planning = await _getOrCreateChildPlanning(
      familyId: familyId,
      childId: childId,
      dayKind: dayKind,
    );
    final existingMoments = await getMomentsForChildPlanning(
      familyId: familyId,
      childId: childId,
      dayKind: dayKind,
    );
    final insertionIndex = _nextIndexAfter(
      ids: existingMoments.map((existingMoment) => existingMoment.id).toList(),
      sourceId: moment.id,
    );
    final now = DateTime.now();

    final duplicatedMoment = MomentModel(
      id: _firestoreService.generateMomentId(familyId),
      familyId: familyId,
      name: _copyName(moment.name),
      guidanceText: moment.guidanceText,
      iconKey: moment.iconKey,
      position: insertionIndex,
      orderMinutes: moment.orderMinutes,
      hasRoutine: moment.hasRoutine,
      active: moment.active,
      childTimeDisplayType: moment.childTimeDisplayType,
      timerMinutes: moment.timerMinutes,
      maxDurationMinutes: moment.maxDurationMinutes,
      isMultiUse: moment.isMultiUse,
      maxDailyUses: moment.maxDailyUses,
      scheduleMode: moment.scheduleMode,
      weekdays: moment.weekdays,
      singleDate: moment.singleDate,
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
      planning.copyWith(momentIds: reorderedMomentIds),
    );
  }

  Future<void> reorderMoments({
    required String familyId,
    required List<MomentModel> moments,
    required String childId,
    PlanningDayKind dayKind = PlanningDayKind.school,
  }) async {
    final planning = await _getOrCreateChildPlanning(
      familyId: familyId,
      childId: childId,
      dayKind: dayKind,
    );

    await _firestoreService.updateDayType(
      planning.copyWith(momentIds: moments.map((moment) => moment.id).toList()),
    );
  }

  Future<void> clearPlanning({
    required String familyId,
    required String childId,
    required PlanningDayKind dayKind,
  }) async {
    final planning = await _getOrCreateChildPlanning(
      familyId: familyId,
      childId: childId,
      dayKind: dayKind,
    );

    await _firestoreService.updateDayType(
      planning.copyWith(momentIds: const []),
    );
  }

  Future<void> deleteMoment({
    required String familyId,
    required String momentId,
    required String childId,
    PlanningDayKind dayKind = PlanningDayKind.school,
  }) async {
    final planning = await _getOrCreateChildPlanning(
      familyId: familyId,
      childId: childId,
      dayKind: dayKind,
    );
    final momentIds = planning.momentIds
        .where((existingMomentId) => existingMomentId != momentId)
        .toList();

    await _firestoreService.updateDayType(
      planning.copyWith(momentIds: momentIds),
    );
  }

  Future<void> duplicatePlanningRhythm({
    required String familyId,
    required PlanningDayKind sourceDayKind,
    required PlanningDayKind targetDayKind,
    required String childId,
  }) async {
    if (sourceDayKind == targetDayKind) {
      return;
    }

    final sourcePlanning = await _getOrCreateChildPlanning(
      familyId: familyId,
      childId: childId,
      dayKind: sourceDayKind,
    );
    final targetPlanning = await _getOrCreateChildPlanning(
      familyId: familyId,
      childId: childId,
      dayKind: targetDayKind,
    );
    final moments = await _firestoreService.getMoments(familyId: familyId);
    final sourceMoments = _momentsFromPlanning(
      planning: sourcePlanning,
      moments: moments,
    );
    final copiedMomentIds = <String>[];

    for (var index = 0; index < sourceMoments.length; index++) {
      final sourceMoment = sourceMoments[index];
      final copiedMoment = sourceMoment.copyWith(
        id: _firestoreService.generateMomentId(familyId),
        position: index,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createMoment(
        familyId: familyId,
        moment: copiedMoment,
      );
      copiedMomentIds.add(copiedMoment.id);
    }

    await _firestoreService.updateDayType(
      targetPlanning.copyWith(momentIds: copiedMomentIds),
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

  Future<DayTypeModel?> _getChildPlanning({
    required String familyId,
    required String childId,
    required PlanningDayKind dayKind,
  }) async {
    return _firestoreService.getDayTypeByType(
      familyId: familyId,
      type: _childPlanningType(childId: childId, dayKind: dayKind),
    );
  }

  Future<DayTypeModel> _getOrCreateChildPlanning({
    required String familyId,
    required String childId,
    required PlanningDayKind dayKind,
  }) async {
    final planningType = _childPlanningType(childId: childId, dayKind: dayKind);
    final existingPlanning = await _firestoreService.getDayTypeByType(
      familyId: familyId,
      type: planningType,
    );

    if (existingPlanning != null) {
      return existingPlanning;
    }

    final planning = DayTypeModel(
      id: _firestoreService.generateDayTypeId(familyId),
      familyId: familyId,
      name: dayKind.label,
      type: planningType,
      order: _planningOrder(dayKind),
      momentIds: const [],
      active: true,
    );

    await _firestoreService.createDayType(planning);

    return planning;
  }

  Future<void> _initializeChildPlannings(ChildModel child) async {
    for (final dayKind in PlanningDayKind.values) {
      final existingPlanning = await _getChildPlanning(
        familyId: child.familyId,
        childId: child.id,
        dayKind: dayKind,
      );

      if (existingPlanning != null) {
        continue;
      }

      final planningType = _childPlanningType(
        childId: child.id,
        dayKind: dayKind,
      );
      final momentIds = <String>[];

      for (
        var index = 0;
        index < initialChildPlanningPresetKeys.length;
        index++
      ) {
        final presetKey = initialChildPlanningPresetKeys[index];
        final momentId = '${planningType}_$presetKey';
        final moment = _buildMomentFromPreset(
          familyId: child.familyId,
          presetKey: presetKey,
          id: momentId,
          position: index,
        );

        await _firestoreService.createMoment(
          familyId: child.familyId,
          moment: moment,
        );
        momentIds.add(momentId);
      }

      await _firestoreService.createDayType(
        DayTypeModel(
          id: planningType,
          familyId: child.familyId,
          name: dayKind.label,
          type: planningType,
          order: _planningOrder(dayKind),
          momentIds: momentIds,
          active: true,
        ),
      );
    }
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

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  int _planningOrder(PlanningDayKind dayKind) {
    return switch (dayKind) {
      PlanningDayKind.school => 0,
      PlanningDayKind.wednesday => 1,
      PlanningDayKind.weekend => 2,
      PlanningDayKind.vacation => 3,
    };
  }

  String _childPlanningType({
    required String childId,
    required PlanningDayKind dayKind,
  }) {
    return switch (dayKind) {
      PlanningDayKind.school => 'child_planning_${childId}_school',
      PlanningDayKind.wednesday => 'child_planning_${childId}_wednesday',
      PlanningDayKind.weekend => 'child_planning_${childId}_weekend',
      PlanningDayKind.vacation => 'child_planning_${childId}_vacation',
    };
  }

  List<MomentModel> _momentsFromPlanning({
    required DayTypeModel planning,
    required List<MomentModel> moments,
  }) {
    final momentsById = {for (final moment in moments) moment.id: moment};

    return [
      for (final momentId in planning.momentIds)
        if (momentsById[momentId] != null) momentsById[momentId]!,
    ];
  }

  int _compareMomentsBySchedule(MomentModel a, MomentModel b) {
    return _compareScheduleOrder(
      aOrderMinutes: a.orderMinutes,
      bOrderMinutes: b.orderMinutes,
      aTitle: a.name,
      bTitle: b.name,
    );
  }

  int _compareScheduleOrder({
    required int? aOrderMinutes,
    required int? bOrderMinutes,
    required String aTitle,
    required String bTitle,
  }) {
    final orderComparison = switch ((aOrderMinutes, bOrderMinutes)) {
      (null, null) => 0,
      (null, _) => 1,
      (_, null) => -1,
      _ => aOrderMinutes!.compareTo(bOrderMinutes!),
    };

    if (orderComparison != 0) {
      return orderComparison;
    }

    return aTitle.compareTo(bTitle);
  }

  List<MomentModel> _momentsScheduledForDate({
    required List<MomentModel> moments,
    required DateTime date,
  }) {
    return [
      for (final moment in moments)
        if (_isMomentScheduledForDate(moment: moment, date: date)) moment,
    ];
  }

  bool _isMomentScheduledForDate({
    required MomentModel moment,
    required DateTime date,
  }) {
    return switch (moment.scheduleMode) {
      MomentScheduleModes.daily => true,
      MomentScheduleModes.weekdays ||
      MomentScheduleModes.weekly => moment.weekdays.contains(date.weekday),
      MomentScheduleModes.singleDate =>
        moment.singleDate != null &&
            _dateOnly(moment.singleDate!) == _dateOnly(date),
      _ => true,
    };
  }

  int _compareEvents(FamilyEventModel a, FamilyEventModel b) {
    final dateComparison = a.date.compareTo(b.date);

    if (dateComparison != 0) {
      return dateComparison;
    }

    return (a.time ?? '').compareTo(b.time ?? '');
  }

  int _eventOrderMinutes(FamilyEventModel event) {
    if (event.isAllDay) {
      return 8 * 60;
    }

    return _parseOrderMinutes(event.time) ?? 8 * 60;
  }

  int? _parseOrderMinutes(String? value) {
    final normalized = value?.trim().replaceAll('h', ':');

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    final parts = normalized.split(':');

    if (parts.length != 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return null;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return hour * 60 + minute;
  }

  String _eventProgressId(String eventId) {
    return 'event:$eventId';
  }

  String _eventIconKey(FamilyEventModel event) {
    if (event.isSensitiveMoment) {
      return 'sensitiveEvent';
    }

    return switch (event.type) {
      'sante' => 'healthEvent',
      'ecole' => 'schoolEvent',
      'activite' => 'activityEvent',
      'anniversaire' => 'birthdayEvent',
      'rendezVous' => 'appointmentEvent',
      _ => 'familyEvent',
    };
  }

  String _eventColorKey(String type) {
    return switch (type) {
      'sante' => 'eventHealth',
      'ecole' => 'eventSchool',
      'activite' => 'eventActivity',
      'anniversaire' => 'eventBirthday',
      'rendezVous' => 'eventAppointment',
      _ => 'eventFamily',
    };
  }

  String? _cleanOptional(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  void _validateEvent(FamilyEventModel event) {
    if (event.title.trim().isEmpty) {
      throw Exception("Merci d'indiquer un titre.");
    }

    if (event.type.trim().isEmpty) {
      throw Exception("Merci de choisir un type.");
    }

    if (event.memberIds.isEmpty) {
      throw Exception("Choisissez au moins un membre.");
    }

    if (![
      'none',
      'timer',
      'maxDuration',
    ].contains(event.childTimeDisplayType)) {
      throw Exception("Choisissez un repère temps valide.");
    }

    if (event.childTimeDisplayType == 'timer' &&
        (event.timerMinutes == null || event.timerMinutes! <= 0)) {
      throw Exception("Indiquez une durée en minutes.");
    }

    if (event.childTimeDisplayType == 'maxDuration' &&
        (event.maxDurationMinutes == null || event.maxDurationMinutes! <= 0)) {
      throw Exception("Indiquez une durée maximum en minutes.");
    }
  }

  MomentModel _buildDefaultMoment({
    required String familyId,
    required String presetKey,
    required int position,
    int? orderMinutes,
    String childTimeDisplayType = 'none',
    int? timerMinutes,
    int? maxDurationMinutes,
    bool isMultiUse = false,
    int? maxDailyUses,
  }) {
    final id = _firestoreService.generateMomentId(familyId);
    final now = DateTime.now();

    switch (presetKey) {
      case 'routine_morning':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Rituel du matin',
          iconKey: 'routineMorning',
          position: position,
          orderMinutes: orderMinutes,
          hasRoutine: true,
          isMultiUse: isMultiUse,
          maxDailyUses: isMultiUse ? maxDailyUses : null,
          active: true,
          createdAt: now,
        );
      case 'breakfast':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Petit-déjeuner',
          iconKey: 'breakfast',
          position: position,
          orderMinutes: orderMinutes ?? 8 * 60,
          hasRoutine: false,
          childTimeDisplayType: childTimeDisplayType,
          timerMinutes: childTimeDisplayType == 'timer' ? timerMinutes : null,
          maxDurationMinutes: childTimeDisplayType == 'maxDuration'
              ? maxDurationMinutes
              : null,
          isMultiUse: isMultiUse,
          maxDailyUses: isMultiUse ? maxDailyUses : null,
          active: true,
          createdAt: now,
        );
      case 'school':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Devoirs',
          iconKey: 'homework',
          position: position,
          orderMinutes: orderMinutes,
          hasRoutine: false,
          childTimeDisplayType: childTimeDisplayType,
          timerMinutes: childTimeDisplayType == 'timer' ? timerMinutes : null,
          maxDurationMinutes: childTimeDisplayType == 'maxDuration'
              ? maxDurationMinutes
              : null,
          isMultiUse: isMultiUse,
          maxDailyUses: isMultiUse ? maxDailyUses : null,
          active: true,
          createdAt: now,
        );
      case 'school_bag':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'École',
          iconKey: 'school_bag',
          position: position,
          orderMinutes: orderMinutes,
          hasRoutine: false,
          childTimeDisplayType: childTimeDisplayType,
          timerMinutes: childTimeDisplayType == 'timer' ? timerMinutes : null,
          maxDurationMinutes: childTimeDisplayType == 'maxDuration'
              ? maxDurationMinutes
              : null,
          isMultiUse: isMultiUse,
          maxDailyUses: isMultiUse ? maxDailyUses : null,
          active: true,
          createdAt: now,
        );
      case 'leisure':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Temps libre',
          iconKey: 'videoGames',
          position: position,
          orderMinutes: orderMinutes,
          hasRoutine: false,
          childTimeDisplayType: childTimeDisplayType,
          timerMinutes: childTimeDisplayType == 'timer' ? timerMinutes : null,
          maxDurationMinutes: childTimeDisplayType == 'maxDuration'
              ? maxDurationMinutes
              : null,
          isMultiUse: isMultiUse,
          maxDailyUses: isMultiUse ? maxDailyUses : null,
          active: true,
          createdAt: now,
        );
      case 'video_games':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Jeux vidéo',
          iconKey: 'video_games',
          position: position,
          orderMinutes: orderMinutes,
          hasRoutine: false,
          childTimeDisplayType: childTimeDisplayType,
          timerMinutes: childTimeDisplayType == 'timer' ? timerMinutes : null,
          maxDurationMinutes: childTimeDisplayType == 'maxDuration'
              ? maxDurationMinutes
              : null,
          isMultiUse: isMultiUse,
          maxDailyUses: isMultiUse ? maxDailyUses : null,
          active: true,
          createdAt: now,
        );
      case 'routine_evening':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Rituel du soir',
          iconKey: 'routineEvening',
          position: position,
          orderMinutes: orderMinutes,
          hasRoutine: true,
          isMultiUse: isMultiUse,
          maxDailyUses: isMultiUse ? maxDailyUses : null,
          active: true,
          createdAt: now,
        );
      case 'bike':
        return MomentModel(
          id: id,
          familyId: familyId,
          name: 'Vélo',
          iconKey: 'bike',
          position: position,
          orderMinutes: orderMinutes,
          hasRoutine: false,
          childTimeDisplayType: childTimeDisplayType,
          timerMinutes: childTimeDisplayType == 'timer' ? timerMinutes : null,
          maxDurationMinutes: childTimeDisplayType == 'maxDuration'
              ? maxDurationMinutes
              : null,
          isMultiUse: isMultiUse,
          maxDailyUses: isMultiUse ? maxDailyUses : null,
          active: true,
          createdAt: now,
        );
      default:
        return _buildMomentFromPreset(
          familyId: familyId,
          presetKey: presetKey,
          position: position,
          orderMinutes: orderMinutes,
          childTimeDisplayType: childTimeDisplayType,
          timerMinutes: timerMinutes,
          maxDurationMinutes: maxDurationMinutes,
          isMultiUse: isMultiUse,
          maxDailyUses: maxDailyUses,
        );
    }
  }

  MomentModel _buildMomentFromPreset({
    required String familyId,
    required String presetKey,
    String? id,
    required int position,
    int? orderMinutes,
    String childTimeDisplayType = 'none',
    int? timerMinutes,
    int? maxDurationMinutes,
    bool isMultiUse = false,
    int? maxDailyUses,
  }) {
    final preset = momentPresetByKey(presetKey);

    return MomentModel(
      id: id ?? _firestoreService.generateMomentId(familyId),
      familyId: familyId,
      name: preset.requiresCustomName ? '' : preset.name,
      iconKey: preset.iconKey,
      position: position,
      orderMinutes: orderMinutes ?? preset.orderMinutes,
      hasRoutine: preset.hasRoutine,
      childTimeDisplayType: childTimeDisplayType,
      timerMinutes: childTimeDisplayType == 'timer' ? timerMinutes : null,
      maxDurationMinutes: childTimeDisplayType == 'maxDuration'
          ? maxDurationMinutes
          : null,
      isMultiUse: isMultiUse,
      maxDailyUses: isMultiUse ? maxDailyUses : null,
      active: true,
      createdAt: DateTime.now(),
    );
  }

  bool _canUseMomentTimeOptions(String presetKey) {
    return ![
      'routine_morning',
      'breakfast',
      'lunch',
      'dinner',
      'routine_evening',
      'wake_up',
      'sleep',
    ].contains(presetKey);
  }

  bool _canUseMomentTimeOptionsForMoment(MomentModel moment) {
    if (moment.iconKey == 'routineMorning' ||
        moment.iconKey == 'routineEvening' ||
        moment.iconKey == 'breakfast' ||
        moment.iconKey == 'lunch' ||
        moment.iconKey == 'dinner' ||
        moment.iconKey == 'wake_up' ||
        moment.iconKey == 'sleep' ||
        moment.iconKey == 'householdTasks') {
      return false;
    }

    return true;
  }

  MomentModel _sanitizeMomentSettings(MomentModel moment) {
    final timeSanitizedMoment = _canUseMomentTimeOptionsForMoment(moment)
        ? moment
        : moment.copyWith(
            childTimeDisplayType: 'none',
            timerMinutes: null,
            maxDurationMinutes: null,
          );

    final scheduleMode =
        MomentScheduleModes.values.contains(timeSanitizedMoment.scheduleMode)
        ? timeSanitizedMoment.scheduleMode
        : MomentScheduleModes.daily;
    final weekdays =
        timeSanitizedMoment.weekdays
            .where(
              (weekday) =>
                  weekday >= DateTime.monday && weekday <= DateTime.sunday,
            )
            .toSet()
            .toList()
          ..sort();
    final scheduleSanitizedMoment = timeSanitizedMoment.copyWith(
      scheduleMode: scheduleMode,
      weekdays:
          scheduleMode == MomentScheduleModes.weekdays ||
              scheduleMode == MomentScheduleModes.weekly
          ? weekdays
          : const [],
      singleDate: scheduleMode == MomentScheduleModes.singleDate
          ? timeSanitizedMoment.singleDate
          : null,
    );

    return scheduleSanitizedMoment.isMultiUse
        ? scheduleSanitizedMoment
        : scheduleSanitizedMoment.copyWith(maxDailyUses: null);
  }

  String? _cleanRequiredOverride(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
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
      final family = await _firestoreService.getFamily(familyId: familyId);

      if (family == null) {
        return null;
      }

      return SessionModel(
        userId: user.uid,
        familyId: familyId,
        firstName: family.name,
        email: user.email ?? '',
        avatar: '',
        role: UserRole.parent,
      );
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
