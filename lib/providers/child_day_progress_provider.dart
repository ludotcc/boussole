import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family_provider.dart';
import 'moments_provider.dart';
import 'session_provider.dart';

const _unset = Object();

enum ChildMomentStatus { todo, inProgress, done }

class ChildDayProgressState {
  const ChildDayProgressState({
    this.childId,
    this.dateKey,
    this.currentMomentId,
    this.completedMomentIds = const {},
    this.startedAtByMomentId = const {},
    this.dailyUseCountsByMomentId = const {},
    this.customOrderItemIds = const [],
    this.dismissedMomentIds = const [],
    this.isLoading = false,
  });

  final String? childId;
  final String? dateKey;
  final String? currentMomentId;
  final Set<String> completedMomentIds;
  final Map<String, DateTime> startedAtByMomentId;
  final Map<String, int> dailyUseCountsByMomentId;
  final List<String> customOrderItemIds;
  final List<String> dismissedMomentIds;
  final bool isLoading;

  DateTime? startedAtFor(String momentId) {
    return startedAtByMomentId[momentId];
  }

  int useCountFor(String momentId) {
    return dailyUseCountsByMomentId[momentId] ?? 0;
  }

  int? remainingUsesFor({
    required String momentId,
    required bool isMultiUse,
    required int? maxDailyUses,
  }) {
    if (!isMultiUse || maxDailyUses == null) {
      return null;
    }

    return (maxDailyUses - useCountFor(momentId))
        .clamp(0, maxDailyUses)
        .toInt();
  }

  bool canStart({
    required String momentId,
    bool isMultiUse = false,
    int? maxDailyUses,
  }) {
    if (!isMultiUse) {
      return !completedMomentIds.contains(momentId);
    }

    final remainingUses = remainingUsesFor(
      momentId: momentId,
      isMultiUse: isMultiUse,
      maxDailyUses: maxDailyUses,
    );

    return remainingUses == null || remainingUses > 0;
  }

  ChildMomentStatus statusFor(
    String momentId, {
    bool isMultiUse = false,
    int? maxDailyUses,
  }) {
    if (isMultiUse &&
        maxDailyUses != null &&
        useCountFor(momentId) >= maxDailyUses) {
      return ChildMomentStatus.done;
    }

    if (completedMomentIds.contains(momentId)) {
      return ChildMomentStatus.done;
    }

    if (currentMomentId == momentId) {
      return ChildMomentStatus.inProgress;
    }

    return ChildMomentStatus.todo;
  }

  List<String> orderedItemIds(List<String> itemIds) {
    if (customOrderItemIds.isEmpty) {
      return itemIds;
    }

    final availableIds = itemIds.toSet();
    final orderedIds = [
      for (final itemId in customOrderItemIds)
        if (availableIds.contains(itemId)) itemId,
    ];

    return [
      ...orderedIds,
      for (final itemId in itemIds)
        if (!orderedIds.contains(itemId)) itemId,
    ];
  }

  bool isDismissed(String momentId) {
    return dismissedMomentIds.contains(momentId);
  }

  ChildDayProgressState copyWith({
    String? childId,
    String? dateKey,
    Object? currentMomentId = _unset,
    Set<String>? completedMomentIds,
    Map<String, DateTime>? startedAtByMomentId,
    Map<String, int>? dailyUseCountsByMomentId,
    List<String>? customOrderItemIds,
    List<String>? dismissedMomentIds,
    bool? isLoading,
  }) {
    return ChildDayProgressState(
      childId: childId ?? this.childId,
      dateKey: dateKey ?? this.dateKey,
      currentMomentId: currentMomentId == _unset
          ? this.currentMomentId
          : currentMomentId as String?,
      completedMomentIds: completedMomentIds ?? this.completedMomentIds,
      startedAtByMomentId: startedAtByMomentId ?? this.startedAtByMomentId,
      dailyUseCountsByMomentId:
          dailyUseCountsByMomentId ?? this.dailyUseCountsByMomentId,
      customOrderItemIds: customOrderItemIds ?? this.customOrderItemIds,
      dismissedMomentIds: dismissedMomentIds ?? this.dismissedMomentIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChildDayProgressNotifier extends StateNotifier<ChildDayProgressState> {
  ChildDayProgressNotifier(this.ref) : super(const ChildDayProgressState());

  final Ref ref;

  Future<void> loadForToday({
    required String childId,
    required List<String> momentIds,
  }) async {
    final session = ref.read(sessionProvider);

    if (session == null || session.familyId.isEmpty) {
      return;
    }

    final date = DateTime.now();
    final dateKey = _dateKey(date);

    if (state.childId == childId &&
        state.dateKey == dateKey &&
        !_needsMomentSync(momentIds)) {
      return;
    }

    state = state.copyWith(childId: childId, dateKey: dateKey, isLoading: true);

    final progress = await ref
        .read(familyRepositoryProvider)
        .getChildDayProgress(
          familyId: session.familyId,
          childId: childId,
          date: date,
        );

    final statuses = progress?.momentStatuses ?? const <String, String>{};
    final startedAtByMomentId = progress?.startedAtByMomentId ?? const {};
    final dailyUseCountsByMomentId =
        progress?.dailyUseCountsByMomentId ?? const <String, int>{};
    final customOrderItemIds = progress?.customOrderItemIds ?? const <String>[];
    final dismissedMomentIds = progress?.dismissedMomentIds ?? const <String>[];
    final completedMomentIds = <String>{
      for (final entry in statuses.entries)
        if (entry.value == 'done' && momentIds.contains(entry.key)) entry.key,
    };
    String? restoredCurrentMomentId;

    for (final entry in statuses.entries) {
      if (entry.value == 'in_progress' && momentIds.contains(entry.key)) {
        restoredCurrentMomentId = entry.key;
        break;
      }
    }

    state = ChildDayProgressState(
      childId: childId,
      dateKey: dateKey,
      currentMomentId: restoredCurrentMomentId,
      completedMomentIds: completedMomentIds,
      startedAtByMomentId: {
        for (final entry in startedAtByMomentId.entries)
          if (momentIds.contains(entry.key)) entry.key: entry.value,
      },
      dailyUseCountsByMomentId: {
        for (final entry in dailyUseCountsByMomentId.entries)
          if (momentIds.contains(entry.key)) entry.key: entry.value,
      },
      customOrderItemIds: [
        for (final itemId in customOrderItemIds)
          if (momentIds.contains(itemId)) itemId,
      ],
      dismissedMomentIds: [
        for (final momentId in dismissedMomentIds)
          if (momentIds.contains(momentId)) momentId,
      ],
    );
  }

  Future<void> restoreTodayMoment({
    required String childId,
    required String momentId,
    required List<String> momentIds,
  }) async {
    if (!state.dismissedMomentIds.contains(momentId)) {
      return;
    }

    final dismissed = List<String>.from(state.dismissedMomentIds)
      ..remove(momentId);

    state = state.copyWith(
      childId: childId,
      dateKey: _dateKey(DateTime.now()),
      dismissedMomentIds: dismissed,
    );

    await _save(childId: childId, momentIds: momentIds);
  }

  Future<void> dismissTodayMoment({
    required String childId,
    required String momentId,
    required List<String> momentIds,
  }) async {
    if (state.statusFor(momentId) != ChildMomentStatus.done) {
      return;
    }

    state = state.copyWith(
      childId: childId,
      dateKey: _dateKey(DateTime.now()),
      dismissedMomentIds: {...state.dismissedMomentIds, momentId}.toList(),
    );

    await _save(childId: childId, momentIds: momentIds);
  }

  Future<void> forgetMoment({
    required String childId,
    required String momentId,
    required List<String> momentIds,
  }) async {
    final completedMomentIds = {...state.completedMomentIds}..remove(momentId);
    final startedAtByMomentId = {...state.startedAtByMomentId}
      ..remove(momentId);
    final dailyUseCountsByMomentId = {...state.dailyUseCountsByMomentId}
      ..remove(momentId);

    state = state.copyWith(
      childId: childId,
      dateKey: _dateKey(DateTime.now()),
      currentMomentId: state.currentMomentId == momentId
          ? null
          : state.currentMomentId,
      completedMomentIds: completedMomentIds,
      startedAtByMomentId: startedAtByMomentId,
      dailyUseCountsByMomentId: dailyUseCountsByMomentId,
      customOrderItemIds: state.customOrderItemIds
          .where((id) => id != momentId)
          .toList(),
      dismissedMomentIds: state.dismissedMomentIds
          .where((id) => id != momentId)
          .toList(),
    );

    await _save(
      childId: childId,
      momentIds: momentIds.where((id) => id != momentId).toList(),
    );
  }

  Future<void> startMoment({
    required String childId,
    required String momentId,
    required List<String> momentIds,
    bool isMultiUse = false,
    int? maxDailyUses,
  }) async {
    if (!state.canStart(
      momentId: momentId,
      isMultiUse: isMultiUse,
      maxDailyUses: maxDailyUses,
    )) {
      return;
    }

    final startedAtByMomentId = {...state.startedAtByMomentId};
    startedAtByMomentId.putIfAbsent(momentId, DateTime.now);

    state = state.copyWith(
      childId: childId,
      dateKey: _dateKey(DateTime.now()),
      currentMomentId: momentId,
      startedAtByMomentId: startedAtByMomentId,
    );

    await _save(childId: childId, momentIds: momentIds);
  }

  Future<void> completeMoment({
    required String childId,
    required String momentId,
    required List<String> momentIds,
    bool isMultiUse = false,
    int? maxDailyUses,
  }) async {
    final dailyUseCountsByMomentId = {...state.dailyUseCountsByMomentId};
    final completedMomentIds = {...state.completedMomentIds};

    if (isMultiUse) {
      dailyUseCountsByMomentId[momentId] =
          (dailyUseCountsByMomentId[momentId] ?? 0) + 1;

      if (maxDailyUses != null &&
          dailyUseCountsByMomentId[momentId]! >= maxDailyUses) {
        completedMomentIds.add(momentId);
      } else {
        completedMomentIds.remove(momentId);
      }
    } else {
      completedMomentIds.add(momentId);
    }

    state = ChildDayProgressState(
      childId: childId,
      dateKey: _dateKey(DateTime.now()),
      currentMomentId: null,
      completedMomentIds: completedMomentIds,
      startedAtByMomentId: state.startedAtByMomentId,
      dailyUseCountsByMomentId: dailyUseCountsByMomentId,
      customOrderItemIds: state.customOrderItemIds,
      dismissedMomentIds: state.dismissedMomentIds,
    );

    await _save(childId: childId, momentIds: momentIds);
  }

  Future<void> resetToday({
    required String childId,
    required List<String> momentIds,
  }) async {
    final session = ref.read(sessionProvider);
    final date = DateTime.now();

    if (session == null || session.familyId.isEmpty) {
      return;
    }

    await ref
        .read(familyRepositoryProvider)
        .deleteDayExceptionForDate(
          familyId: session.familyId,
          childId: childId,
          date: date,
        );

    state = ChildDayProgressState(childId: childId, dateKey: _dateKey(date));

    await _save(childId: childId, momentIds: momentIds);
    ref.invalidate(childDayItemsProvider(childId));
  }

  Future<void> reorderTodayItems({
    required String childId,
    required List<String> itemIds,
    required List<String> momentIds,
  }) async {
    state = state.copyWith(
      childId: childId,
      dateKey: _dateKey(DateTime.now()),
      customOrderItemIds: itemIds,
    );

    await _save(childId: childId, momentIds: momentIds);
  }

  Future<void> restoreProgressSnapshot({
    required String childId,
    required List<String> momentIds,
    required String? currentMomentId,
    required Set<String> completedMomentIds,
    required Map<String, DateTime> startedAtByMomentId,
    required Map<String, int> dailyUseCountsByMomentId,
    required List<String> customOrderItemIds,
    required List<String> dismissedMomentIds,
  }) async {
    state = ChildDayProgressState(
      childId: childId,
      dateKey: _dateKey(DateTime.now()),
      currentMomentId: currentMomentId,
      completedMomentIds: {...completedMomentIds},
      startedAtByMomentId: {...startedAtByMomentId},
      dailyUseCountsByMomentId: {...dailyUseCountsByMomentId},
      customOrderItemIds: [...customOrderItemIds],
      dismissedMomentIds: [...dismissedMomentIds],
    );

    await _save(childId: childId, momentIds: momentIds);
  }

  Future<void> _save({
    required String childId,
    required List<String> momentIds,
  }) async {
    final session = ref.read(sessionProvider);

    if (session == null || session.familyId.isEmpty) {
      return;
    }

    await ref
        .read(familyRepositoryProvider)
        .saveChildDayProgress(
          familyId: session.familyId,
          childId: childId,
          date: DateTime.now(),
          momentStatuses: _statusesByMomentId(momentIds),
          startedAtByMomentId: state.startedAtByMomentId,
          dailyUseCountsByMomentId: state.dailyUseCountsByMomentId,
          customOrderItemIds: state.customOrderItemIds,
          dismissedMomentIds: state.dismissedMomentIds,
        );
  }

  Map<String, String> _statusesByMomentId(List<String> momentIds) {
    return {for (final momentId in momentIds) momentId: _statusValue(momentId)};
  }

  String _statusValue(String momentId) {
    return switch (state.statusFor(momentId)) {
      ChildMomentStatus.todo => 'todo',
      ChildMomentStatus.inProgress => 'in_progress',
      ChildMomentStatus.done => 'done',
    };
  }

  bool _needsMomentSync(List<String> momentIds) {
    if (state.currentMomentId != null &&
        !momentIds.contains(state.currentMomentId)) {
      return true;
    }

    return state.completedMomentIds.any(
          (momentId) => !momentIds.contains(momentId),
        ) ||
        state.startedAtByMomentId.keys.any(
          (momentId) => !momentIds.contains(momentId),
        ) ||
        state.dailyUseCountsByMomentId.keys.any(
          (momentId) => !momentIds.contains(momentId),
        ) ||
        state.customOrderItemIds.any(
          (momentId) => !momentIds.contains(momentId),
        ) ||
        state.dismissedMomentIds.any(
          (momentId) => !momentIds.contains(momentId),
        );
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

final childDayProgressProvider =
    StateNotifierProvider<ChildDayProgressNotifier, ChildDayProgressState>(
      (ref) => ChildDayProgressNotifier(ref),
    );
