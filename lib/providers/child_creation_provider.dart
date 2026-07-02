import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/child_creation_model.dart';

class ChildCreationNotifier extends StateNotifier<ChildCreationModel?> {
  ChildCreationNotifier() : super(null);

  void createDraft({required String firstName, required int age}) {
    state = ChildCreationModel(firstName: firstName, age: age, avatar: '');
  }

  void updateAvatar(String avatar) {
    if (state == null) return;

    state = state!.copyWith(avatar: avatar);
  }

  void clear() {
    state = null;
  }
}

final childCreationProvider =
    StateNotifierProvider<ChildCreationNotifier, ChildCreationModel?>(
      (ref) => ChildCreationNotifier(),
    );
