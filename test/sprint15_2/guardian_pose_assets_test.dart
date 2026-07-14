import 'dart:io';

import 'package:boussole/models/guardian_experience_state.dart';
import 'package:boussole/models/guardian_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le catalogue contient cinq Gardiens et quarante poses uniques', () {
    expect(GuardianModel.all, hasLength(5));
    expect(guardianPoseAssets, hasLength(5));

    final paths = <String>{};
    for (final guardian in GuardianModel.all) {
      final poses = guardianPoseAssets[guardian.id]!;
      expect(poses, hasLength(8));
      expect(poses.keys.toSet(), GuardianPose.values.toSet());
      for (final path in poses.values) {
        expect(path, isNotEmpty);
        expect(File(path).existsSync(), isTrue, reason: path);
        paths.add(path);
      }
    }
    expect(paths, hasLength(40));
  });

  for (final guardian in GuardianModel.all) {
    test('${guardian.name} résout correctement ses huit poses', () {
      for (final pose in GuardianPose.values) {
        final asset = resolveGuardianAsset(guardianId: guardian.id, pose: pose);
        expect(asset, guardianPoseAssets[guardian.id]![pose]);
        expect(
          asset,
          contains('/${guardian.id.name}/guardian_${guardian.id.name}_'),
        );
      }
    });
  }

  test('le fallback idle reste celui du Gardien actif', () {
    for (final guardian in GuardianModel.all.where(
      (item) => item.id != GuardianId.crystal,
    )) {
      final idle = guardianPoseAssets[guardian.id]![GuardianPose.idle];
      expect(idle, guardian.idleAsset);
      expect(idle, isNot(contains('/crystal/')));
    }
  });

  test('le manifeste Flutter déclare les cinq dossiers de Gardiens', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final guardian in GuardianId.values) {
      expect(pubspec, contains('- assets/images/guardians/${guardian.name}/'));
    }
  });
}
