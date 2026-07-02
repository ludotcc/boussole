import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session_model.dart';

class SessionNotifier extends StateNotifier<SessionModel?> {
  SessionNotifier() : super(null);

  void setSession(SessionModel session) {
    state = session;
  }

  void updateAvatar(String avatar) {
    if (state == null) return;

    state = state!.copyWith(avatar: avatar);
  }

  void clearSession() {
    state = null;
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionModel?>(
  (ref) => SessionNotifier(),
);
