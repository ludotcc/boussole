import 'package:boussole/models/device_configuration_model.dart';
import 'package:boussole/models/device_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceConfigurationModel', () {
    test('round-trips the local device configuration', () {
      final updatedAt = DateTime.utc(2026, 7, 14, 12, 30);
      final configuration = DeviceConfigurationModel(
        mode: DeviceMode.sharedChildTablet,
        allowedChildIds: const ['child-a', 'child-b'],
        parentPinSalt: 'salt',
        parentPinVerifier: 'verifier',
        updatedAt: updatedAt,
      );

      final restored = DeviceConfigurationModel.fromMap(configuration.toMap());

      expect(restored.mode, DeviceMode.sharedChildTablet);
      expect(restored.allowedChildIds, ['child-a', 'child-b']);
      expect(restored.hasParentPin, isTrue);
      expect(restored.updatedAt, updatedAt);
      expect(restored.childStartLocation, '/child-select');
    });

    test('limits a personal tablet to its assigned child', () {
      const configuration = DeviceConfigurationModel(
        mode: DeviceMode.personalChildTablet,
        personalChildId: 'child-a',
      );

      expect(configuration.canOpenChild('child-a'), isTrue);
      expect(configuration.canOpenChild('child-b'), isFalse);
      expect(configuration.childStartLocation, '/child/child-a/house');
    });
  });
}
