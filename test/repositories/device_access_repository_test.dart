import 'package:boussole/models/device_configuration_model.dart';
import 'package:boussole/models/device_mode.dart';
import 'package:boussole/repositories/device_access_repository.dart';
import 'package:boussole/services/device_configuration_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryConfigurationStore implements DeviceConfigurationStore {
  DeviceConfigurationModel value = DeviceConfigurationModel.initial();

  @override
  Future<DeviceConfigurationModel> read() async => value;

  @override
  Future<void> write(DeviceConfigurationModel configuration) async {
    value = configuration;
  }
}

void main() {
  test('creates a protected child mode without storing the PIN', () async {
    final store = _MemoryConfigurationStore();
    final repository = DeviceAccessRepository(store: store);

    final configuration = await repository.configure(
      current: store.value,
      mode: DeviceMode.personalChildTablet,
      personalChildId: 'child-a',
      newParentPin: '2580',
    );

    expect(configuration.hasParentPin, isTrue);
    expect(configuration.parentPinVerifier, isNot('2580'));
    expect(await repository.verifyParentPin('2580'), isTrue);
    expect(await repository.verifyParentPin('0000'), isFalse);
  });

  test('rejects incomplete child-device configuration', () async {
    final store = _MemoryConfigurationStore();
    final repository = DeviceAccessRepository(store: store);

    expect(
      () => repository.configure(
        current: store.value,
        mode: DeviceMode.sharedChildTablet,
        newParentPin: '2580',
      ),
      throwsException,
    );
  });
}
