import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'active_child_provider.dart';
import 'device_mode_provider.dart';
import 'family_provider.dart';
import 'parent_access_provider.dart';
import 'session_provider.dart';

class AppBootstrapState {
  const AppBootstrapState({
    this.isLoading = false,
    this.destination,
    this.error,
  });

  final bool isLoading;
  final String? destination;
  final Object? error;
}

class AppBootstrapNotifier extends StateNotifier<AppBootstrapState> {
  AppBootstrapNotifier(this.ref) : super(const AppBootstrapState());

  final Ref ref;

  Future<void> bootstrap() async {
    if (state.isLoading) return;
    state = const AppBootstrapState(isLoading: true);

    try {
      final configuration = await ref
          .read(deviceConfigurationProvider.notifier)
          .load();
      ref
          .read(parentAccessProvider.notifier)
          .syncWithConfiguration(configuration);

      final session = await ref.read(familyRepositoryProvider).restoreSession();
      if (session == null) {
        state = const AppBootstrapState(destination: '/welcome');
        return;
      }

      ref.read(sessionProvider.notifier).setSession(session);
      ref.read(activeChildProvider.notifier).state =
          configuration.personalChildId;
      state = AppBootstrapState(destination: configuration.childStartLocation);
    } catch (error) {
      state = AppBootstrapState(error: error);
    }
  }
}

final appBootstrapProvider =
    StateNotifierProvider<AppBootstrapNotifier, AppBootstrapState>((ref) {
      return AppBootstrapNotifier(ref);
    });
