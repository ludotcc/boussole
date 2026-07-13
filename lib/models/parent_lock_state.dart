class ParentLockState {
  const ParentLockState({
    required this.isLocked,
    this.isChecking = false,
    this.failedAttempts = 0,
    this.blockedUntil,
    this.errorMessage,
  });

  const ParentLockState.unlocked()
    : isLocked = false,
      isChecking = false,
      failedAttempts = 0,
      blockedUntil = null,
      errorMessage = null;

  const ParentLockState.locked()
    : isLocked = true,
      isChecking = false,
      failedAttempts = 0,
      blockedUntil = null,
      errorMessage = null;

  final bool isLocked;
  final bool isChecking;
  final int failedAttempts;
  final DateTime? blockedUntil;
  final String? errorMessage;

  bool get isTemporarilyBlocked =>
      blockedUntil != null && blockedUntil!.isAfter(DateTime.now());

  ParentLockState copyWith({
    bool? isLocked,
    bool? isChecking,
    int? failedAttempts,
    DateTime? blockedUntil,
    bool clearBlockedUntil = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ParentLockState(
      isLocked: isLocked ?? this.isLocked,
      isChecking: isChecking ?? this.isChecking,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      blockedUntil: clearBlockedUntil
          ? null
          : blockedUntil ?? this.blockedUntil,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
