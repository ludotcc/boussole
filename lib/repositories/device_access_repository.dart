import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/device_configuration_model.dart';
import '../models/device_mode.dart';
import '../services/device_configuration_service.dart';

class DeviceAccessRepository {
  DeviceAccessRepository({DeviceConfigurationStore? store})
    : _store = store ?? DeviceConfigurationService();

  final DeviceConfigurationStore _store;

  Future<DeviceConfigurationModel> load() {
    return _store.read();
  }

  Future<DeviceConfigurationModel> configure({
    required DeviceConfigurationModel current,
    required DeviceMode mode,
    String? personalChildId,
    List<String> allowedChildIds = const [],
    String? newParentPin,
  }) async {
    final normalizedAllowedIds = allowedChildIds.toSet().toList();

    if (mode == DeviceMode.personalChildTablet &&
        (personalChildId == null || personalChildId.isEmpty)) {
      throw Exception('Choisissez l’enfant qui utilisera cette tablette.');
    }

    if (mode == DeviceMode.sharedChildTablet && normalizedAllowedIds.isEmpty) {
      throw Exception('Choisissez au moins un enfant autorisé.');
    }

    var salt = current.parentPinSalt;
    var verifier = current.parentPinVerifier;

    if (mode.isChildMode && !current.hasParentPin) {
      _validatePin(newParentPin);
      salt = _createSalt();
      verifier = _derivePinVerifier(newParentPin!, salt);
    }

    final configuration = current.copyWith(
      mode: mode,
      personalChildId: mode == DeviceMode.personalChildTablet
          ? personalChildId
          : null,
      allowedChildIds: mode == DeviceMode.sharedChildTablet
          ? normalizedAllowedIds
          : const [],
      parentPinSalt: salt,
      parentPinVerifier: verifier,
      updatedAt: DateTime.now(),
    );

    await _store.write(configuration);
    return configuration;
  }

  Future<bool> verifyParentPin(String pin) async {
    final configuration = await load();
    if (!configuration.hasParentPin || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      return false;
    }

    return _constantTimeEquals(
      _derivePinVerifier(pin, configuration.parentPinSalt!),
      configuration.parentPinVerifier!,
    );
  }

  void _validatePin(String? pin) {
    if (pin == null || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw Exception('Le PIN parent doit contenir exactement 4 chiffres.');
    }
  }

  String _createSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _derivePinVerifier(String pin, String salt) {
    // A deliberately iterated verifier slows offline guesses while remaining
    // usable on low-end family devices. The UI also enforces attempt limits.
    const iterations = 5000;
    final hmac = Hmac(sha256, utf8.encode(pin));
    final saltBytes = base64Url.decode(salt);
    final block = <int>[...saltBytes, 0, 0, 0, 1];
    var digest = hmac.convert(block).bytes;
    final derived = List<int>.from(digest);

    for (var round = 1; round < iterations; round++) {
      digest = hmac.convert(digest).bytes;
      for (var index = 0; index < derived.length; index++) {
        derived[index] ^= digest[index];
      }
    }

    return base64UrlEncode(derived);
  }

  bool _constantTimeEquals(String left, String right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left.codeUnitAt(index) ^ right.codeUnitAt(index);
    }
    return difference == 0;
  }
}
