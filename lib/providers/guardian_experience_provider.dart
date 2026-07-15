import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/guardian_dialogues.dart';
import '../models/guardian_experience_state.dart';
import '../models/guardian_model.dart';
import 'guardian_provider.dart';

class GuardianExperienceNotifier
    extends StateNotifier<GuardianExperienceState> {
  GuardianExperienceNotifier({
    required this.guardianId,
    DateTime Function()? now,
    this.transientDuration = const Duration(seconds: 5),
  }) : _now = now ?? DateTime.now,
       super(_initialState(guardianId, (now ?? DateTime.now)())) {
    if (!state.isSleeping) _scheduleIdle();
    _scheduleDayBoundary();
  }

  final GuardianId guardianId;
  final DateTime Function() _now;
  final Duration transientDuration;
  Timer? _timer;
  Timer? _dayBoundaryTimer;
  int _variant = 0;

  static GuardianExperienceState _initialState(
    GuardianId guardianId,
    DateTime now,
  ) {
    final pose = now.hour < 5 ? GuardianPose.sleeping : GuardianPose.welcome;
    return GuardianExperienceState(
      pose: pose,
      message: guardianDialogue(guardianId, pose),
    );
  }

  void talk() {
    if (state.pose == GuardianPose.talking) {
      showChoices();
      return;
    }
    if (_isNight(_now())) {
      refreshForCurrentTime();
      return;
    }
    _variant++;
    state = GuardianExperienceState(
      pose: GuardianPose.talking,
      message: guardianDialogue(
        guardianId,
        GuardianPose.talking,
        variant: _variant,
      ),
    );
    _timer?.cancel();
    _timer = Timer(transientDuration, showChoices);
  }

  void showChoices({GuardianChoiceKind kind = GuardianChoiceKind.navigation}) {
    _timer?.cancel();
    state = GuardianExperienceState(
      pose: GuardianPose.choices,
      message: guardianDialogue(guardianId, GuardianPose.choices),
      showChoices: true,
      choiceKind: kind,
    );
  }

  void openCompanion() {
    if (_isNight(_now())) {
      refreshForCurrentTime();
      return;
    }
    showChoices();
  }

  void showSecretMission() {
    _timer?.cancel();
    state = const GuardianExperienceState(
      pose: GuardianPose.talking,
      message: 'Chut… J’ai une Mission Secrète pour toi.',
      showChoices: true,
      choiceKind: GuardianChoiceKind.secretMission,
    );
  }

  void encourage() => _transient(GuardianPose.encourage);

  void reassure() => _transient(GuardianPose.reassure);

  void celebrate() => _transient(GuardianPose.celebrate);

  void showDailyRecap(String message, {required bool celebrate}) {
    if (_isNight(_now())) {
      refreshForCurrentTime();
      return;
    }
    state = GuardianExperienceState(
      pose: celebrate ? GuardianPose.celebrate : GuardianPose.encourage,
      message: message,
    );
    _scheduleIdle();
  }

  void showCompanionMessage(
    String message, {
    GuardianPose pose = GuardianPose.encourage,
  }) {
    if (_isNight(_now())) {
      refreshForCurrentTime();
      return;
    }
    state = GuardianExperienceState(pose: pose, message: message);
    _scheduleIdle();
  }

  void closeChoices() => _setIdle();

  void refreshForCurrentTime() {
    if (_isNight(_now())) {
      _timer?.cancel();
      state = GuardianExperienceState(
        pose: GuardianPose.sleeping,
        message: guardianDialogue(guardianId, GuardianPose.sleeping),
      );
    } else if (state.isSleeping) {
      _setIdle();
    }
    _scheduleDayBoundary();
  }

  void _transient(GuardianPose pose) {
    if (_isNight(_now())) {
      refreshForCurrentTime();
      return;
    }
    _variant++;
    state = GuardianExperienceState(
      pose: pose,
      message: guardianDialogue(guardianId, pose, variant: _variant),
    );
    _scheduleIdle();
  }

  void _scheduleIdle() {
    _timer?.cancel();
    _timer = Timer(transientDuration, _setIdle);
  }

  void _setIdle() {
    if (_isNight(_now())) {
      refreshForCurrentTime();
      return;
    }
    state = GuardianExperienceState(
      pose: GuardianPose.idle,
      message: guardianDialogue(guardianId, GuardianPose.idle),
    );
  }

  bool _isNight(DateTime value) => value.hour < 5;

  void _scheduleDayBoundary() {
    _dayBoundaryTimer?.cancel();
    final current = _now();
    late final DateTime boundary;
    if (current.hour < 5) {
      boundary = DateTime(current.year, current.month, current.day, 5);
    } else {
      final tomorrow = current.add(const Duration(days: 1));
      boundary = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    }
    final delay = boundary.difference(current);
    _dayBoundaryTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      refreshForCurrentTime,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dayBoundaryTimer?.cancel();
    super.dispose();
  }
}

final guardianExperienceProvider =
    StateNotifierProvider.family<
      GuardianExperienceNotifier,
      GuardianExperienceState,
      String
    >((ref, childId) {
      final guardian =
          ref.watch(childGuardianProvider(childId)).valueOrNull ??
          GuardianModel.fromStorageId('wave', fallback: GuardianId.wave);
      return GuardianExperienceNotifier(guardianId: guardian.id);
    });
