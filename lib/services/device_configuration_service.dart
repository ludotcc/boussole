import 'package:hive/hive.dart';

import '../models/device_configuration_model.dart';

abstract class DeviceConfigurationStore {
  Future<DeviceConfigurationModel> read();

  Future<void> write(DeviceConfigurationModel configuration);
}

class DeviceConfigurationService implements DeviceConfigurationStore {
  static const _boxName = 'boussole_device_configuration';
  static const _configurationKey = 'configuration';

  Future<Box<dynamic>> _openBox() {
    return Hive.openBox<dynamic>(_boxName);
  }

  @override
  Future<DeviceConfigurationModel> read() async {
    final box = await _openBox();
    final value = box.get(_configurationKey);

    if (value is Map) {
      return DeviceConfigurationModel.fromMap(value);
    }

    return DeviceConfigurationModel.initial();
  }

  @override
  Future<void> write(DeviceConfigurationModel configuration) async {
    final box = await _openBox();
    await box.put(_configurationKey, configuration.toMap());
  }
}
