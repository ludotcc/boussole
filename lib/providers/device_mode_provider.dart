import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_configuration_model.dart';
import '../models/device_mode.dart';
import '../repositories/device_access_repository.dart';

final deviceAccessRepositoryProvider = Provider<DeviceAccessRepository>((ref) {
  return DeviceAccessRepository();
});

class DeviceConfigurationNotifier
    extends StateNotifier<AsyncValue<DeviceConfigurationModel>> {
  DeviceConfigurationNotifier(this.ref) : super(const AsyncLoading()) {
    Future<void>.microtask(load);
  }

  final Ref ref;

  Future<DeviceConfigurationModel> load() async {
    final configuration = await ref.read(deviceAccessRepositoryProvider).load();
    state = AsyncData(configuration);
    return configuration;
  }

  Future<DeviceConfigurationModel?> configure({
    required DeviceMode mode,
    String? personalChildId,
    List<String> allowedChildIds = const [],
    String? newParentPin,
  }) async {
    final current = state.valueOrNull ?? await load();
    state = const AsyncLoading();

    try {
      final configuration = await ref
          .read(deviceAccessRepositoryProvider)
          .configure(
            current: current,
            mode: mode,
            personalChildId: personalChildId,
            allowedChildIds: allowedChildIds,
            newParentPin: newParentPin,
          );
      state = AsyncData(configuration);
      return configuration;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}

final deviceConfigurationProvider =
    StateNotifierProvider<
      DeviceConfigurationNotifier,
      AsyncValue<DeviceConfigurationModel>
    >((ref) {
      return DeviceConfigurationNotifier(ref);
    });
