import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_configuration_model.dart';
import '../models/parent_lock_state.dart';
import 'device_mode_provider.dart';

class ParentAccessNotifier extends StateNotifier<ParentLockState> {
  ParentAccessNotifier(this.ref) : super(const ParentLockState.unlocked());

  static const _maximumAttempts = 5;
  static const _blockingDuration = Duration(seconds: 30);

  final Ref ref;

  void syncWithConfiguration(DeviceConfigurationModel configuration) {
    state = configuration.isChildMode
        ? const ParentLockState.locked()
        : const ParentLockState.unlocked();
  }

  void lock() {
    state = const ParentLockState.locked();
  }

  Future<bool> unlock(String pin) async {
    if (state.isTemporarilyBlocked) {
      state = state.copyWith(
        errorMessage: 'Patientez quelques instants avant de réessayer.',
      );
      return false;
    }

    state = state.copyWith(isChecking: true, clearError: true);
    final isValid = await ref
        .read(deviceAccessRepositoryProvider)
        .verifyParentPin(pin);

    if (isValid) {
      state = const ParentLockState.unlocked();
      return true;
    }

    final attempts = state.failedAttempts + 1;
    final shouldBlock = attempts >= _maximumAttempts;
    state = ParentLockState(
      isLocked: true,
      failedAttempts: shouldBlock ? 0 : attempts,
      blockedUntil: shouldBlock ? DateTime.now().add(_blockingDuration) : null,
      errorMessage: shouldBlock
          ? 'Trop de tentatives. Réessayez dans 30 secondes.'
          : 'Ce PIN ne correspond pas.',
    );
    return false;
  }
}

final parentAccessProvider =
    StateNotifierProvider<ParentAccessNotifier, ParentLockState>((ref) {
      return ParentAccessNotifier(ref);
    });
