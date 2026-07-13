import 'device_mode.dart';

const _unset = Object();

class DeviceConfigurationModel {
  const DeviceConfigurationModel({
    required this.mode,
    this.personalChildId,
    this.allowedChildIds = const [],
    this.parentPinSalt,
    this.parentPinVerifier,
    this.updatedAt,
  });

  factory DeviceConfigurationModel.initial() {
    return const DeviceConfigurationModel(mode: DeviceMode.familyPhone);
  }

  final DeviceMode mode;
  final String? personalChildId;
  final List<String> allowedChildIds;
  final String? parentPinSalt;
  final String? parentPinVerifier;
  final DateTime? updatedAt;

  bool get isChildMode => mode.isChildMode;

  bool get hasParentPin =>
      parentPinSalt?.isNotEmpty == true &&
      parentPinVerifier?.isNotEmpty == true;

  bool canOpenChild(String childId) {
    return switch (mode) {
      DeviceMode.familyPhone => true,
      DeviceMode.personalChildTablet => personalChildId == childId,
      DeviceMode.sharedChildTablet => allowedChildIds.contains(childId),
    };
  }

  String get childStartLocation {
    return switch (mode) {
      DeviceMode.familyPhone => '/home',
      DeviceMode.personalChildTablet when personalChildId != null =>
        '/child/$personalChildId/house',
      DeviceMode.personalChildTablet => '/child-select',
      DeviceMode.sharedChildTablet => '/child-select',
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'version': 1,
      'mode': mode.value,
      'personalChildId': personalChildId,
      'allowedChildIds': allowedChildIds,
      'parentPinSalt': parentPinSalt,
      'parentPinVerifier': parentPinVerifier,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DeviceConfigurationModel.fromMap(Map<dynamic, dynamic> map) {
    final personalChildId = map['personalChildId'];
    final allowedChildIds = map['allowedChildIds'];
    final updatedAt = map['updatedAt'];

    return DeviceConfigurationModel(
      mode: DeviceMode.fromValue(map['mode'] as String?),
      personalChildId: personalChildId is String && personalChildId.isNotEmpty
          ? personalChildId
          : null,
      allowedChildIds: allowedChildIds is List
          ? allowedChildIds.whereType<String>().toSet().toList()
          : const [],
      parentPinSalt: map['parentPinSalt'] as String?,
      parentPinVerifier: map['parentPinVerifier'] as String?,
      updatedAt: updatedAt is String ? DateTime.tryParse(updatedAt) : null,
    );
  }

  DeviceConfigurationModel copyWith({
    DeviceMode? mode,
    Object? personalChildId = _unset,
    List<String>? allowedChildIds,
    Object? parentPinSalt = _unset,
    Object? parentPinVerifier = _unset,
    Object? updatedAt = _unset,
  }) {
    return DeviceConfigurationModel(
      mode: mode ?? this.mode,
      personalChildId: personalChildId == _unset
          ? this.personalChildId
          : personalChildId as String?,
      allowedChildIds: allowedChildIds ?? this.allowedChildIds,
      parentPinSalt: parentPinSalt == _unset
          ? this.parentPinSalt
          : parentPinSalt as String?,
      parentPinVerifier: parentPinVerifier == _unset
          ? this.parentPinVerifier
          : parentPinVerifier as String?,
      updatedAt: updatedAt == _unset ? this.updatedAt : updatedAt as DateTime?,
    );
  }
}
