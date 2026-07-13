import 'package:boussole/models/device_configuration_model.dart';
import 'package:boussole/providers/device_mode_provider.dart';
import 'package:boussole/providers/parent_access_provider.dart';
import 'package:boussole/repositories/device_access_repository.dart';
import 'package:boussole/services/device_configuration_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _UnusedStore implements DeviceConfigurationStore {
  @override
  Future<DeviceConfigurationModel> read() async =>
      DeviceConfigurationModel.initial();

  @override
  Future<void> write(DeviceConfigurationModel configuration) async {}
}

class _RejectingDeviceAccessRepository extends DeviceAccessRepository {
  _RejectingDeviceAccessRepository() : super(store: _UnusedStore());

  @override
  Future<bool> verifyParentPin(String pin) async => false;
}

void main() {
  test('temporarily blocks parent access after five invalid PINs', () async {
    final container = ProviderContainer(
      overrides: [
        deviceAccessRepositoryProvider.overrideWithValue(
          _RejectingDeviceAccessRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(parentAccessProvider.notifier);
    for (var attempt = 0; attempt < 5; attempt++) {
      expect(await notifier.unlock('0000'), isFalse);
    }

    final state = container.read(parentAccessProvider);
    expect(state.isLocked, isTrue);
    expect(state.isTemporarilyBlocked, isTrue);
    expect(state.errorMessage, contains('30 secondes'));
  });
}
