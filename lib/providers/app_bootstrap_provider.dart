import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'active_child_provider.dart';
import 'device_mode_provider.dart';
import 'family_provider.dart';
import 'parent_access_provider.dart';
import 'session_provider.dart';

class AppBootstrapState {
  const AppBootstrapState({this.destination});

  final String? destination;
}

final appBootstrapProvider = FutureProvider<AppBootstrapState>((ref) async {
  var isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final configuration = await ref
      .read(deviceConfigurationProvider.notifier)
      .load();
  if (isDisposed) return const AppBootstrapState();

  ref.read(parentAccessProvider.notifier).syncWithConfiguration(configuration);

  final session = await ref.read(familyRepositoryProvider).restoreSession();
  if (isDisposed) return const AppBootstrapState();

  if (session == null) {
    return const AppBootstrapState(destination: '/welcome');
  }

  ref.read(sessionProvider.notifier).setSession(session);
  ref.read(activeChildProvider.notifier).state = configuration.personalChildId;

  return AppBootstrapState(destination: configuration.childStartLocation);
});
