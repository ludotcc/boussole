import '../core/app_assets.dart';
import 'guardian_experience_state.dart';

enum GuardianId { crystal, pixel, pyro, gear, wave }

enum GuardianActivity { wakingUp, reading, creating, resting, sleeping }

const Map<GuardianId, Map<GuardianPose, String>> guardianPoseAssets = {
  GuardianId.crystal: {
    GuardianPose.idle: AppAssets.guardianCrystalIdle,
    GuardianPose.welcome: AppAssets.guardianCrystalWelcome,
    GuardianPose.talking: AppAssets.guardianCrystalTalking,
    GuardianPose.choices: AppAssets.guardianCrystalChoices,
    GuardianPose.encourage: AppAssets.guardianCrystalEncourage,
    GuardianPose.reassure: AppAssets.guardianCrystalReassure,
    GuardianPose.celebrate: AppAssets.guardianCrystalCelebrate,
    GuardianPose.sleeping: AppAssets.guardianCrystalSleeping,
  },
  GuardianId.pixel: {
    GuardianPose.idle: AppAssets.guardianPixelIdle,
    GuardianPose.welcome: AppAssets.guardianPixelWelcome,
    GuardianPose.talking: AppAssets.guardianPixelTalking,
    GuardianPose.choices: AppAssets.guardianPixelChoices,
    GuardianPose.encourage: AppAssets.guardianPixelEncourage,
    GuardianPose.reassure: AppAssets.guardianPixelReassure,
    GuardianPose.celebrate: AppAssets.guardianPixelCelebrate,
    GuardianPose.sleeping: AppAssets.guardianPixelSleeping,
  },
  GuardianId.pyro: {
    GuardianPose.idle: AppAssets.guardianPyroIdle,
    GuardianPose.welcome: AppAssets.guardianPyroWelcome,
    GuardianPose.talking: AppAssets.guardianPyroTalking,
    GuardianPose.choices: AppAssets.guardianPyroChoices,
    GuardianPose.encourage: AppAssets.guardianPyroEncourage,
    GuardianPose.reassure: AppAssets.guardianPyroReassure,
    GuardianPose.celebrate: AppAssets.guardianPyroCelebrate,
    GuardianPose.sleeping: AppAssets.guardianPyroSleeping,
  },
  GuardianId.gear: {
    GuardianPose.idle: AppAssets.guardianGearIdle,
    GuardianPose.welcome: AppAssets.guardianGearWelcome,
    GuardianPose.talking: AppAssets.guardianGearTalking,
    GuardianPose.choices: AppAssets.guardianGearChoices,
    GuardianPose.encourage: AppAssets.guardianGearEncourage,
    GuardianPose.reassure: AppAssets.guardianGearReassure,
    GuardianPose.celebrate: AppAssets.guardianGearCelebrate,
    GuardianPose.sleeping: AppAssets.guardianGearSleeping,
  },
  GuardianId.wave: {
    GuardianPose.idle: AppAssets.guardianWaveIdle,
    GuardianPose.welcome: AppAssets.guardianWaveWelcome,
    GuardianPose.talking: AppAssets.guardianWaveTalking,
    GuardianPose.choices: AppAssets.guardianWaveChoices,
    GuardianPose.encourage: AppAssets.guardianWaveEncourage,
    GuardianPose.reassure: AppAssets.guardianWaveReassure,
    GuardianPose.celebrate: AppAssets.guardianWaveCelebrate,
    GuardianPose.sleeping: AppAssets.guardianWaveSleeping,
  },
};

String resolveGuardianAsset({
  required GuardianId guardianId,
  required GuardianPose pose,
}) =>
    guardianPoseAssets[guardianId]?[pose] ??
    guardianPoseAssets[guardianId]![GuardianPose.idle]!;

class GuardianModel {
  const GuardianModel({
    required this.id,
    required this.name,
    required this.personality,
    required this.welcomeMessage,
    required this.color,
    required this.idleAsset,
  });

  final GuardianId id;
  final String name;
  final String personality;
  final String welcomeMessage;
  final int color;
  final String idleAsset;

  String get storageId => id.name;

  int get price => switch (id) {
    GuardianId.wave => 0,
    GuardianId.crystal || GuardianId.pixel => 10,
    GuardianId.pyro || GuardianId.gear => 15,
  };

  String assetFor(GuardianActivity activity) {
    if (id == GuardianId.crystal) {
      if (activity == GuardianActivity.wakingUp) {
        return AppAssets.guardianCrystalWelcome;
      }
      if (activity == GuardianActivity.sleeping) {
        return AppAssets.guardianCrystalSleeping;
      }
    }
    return idleAsset;
  }

  String assetForPose(GuardianPose pose) {
    return resolveGuardianAsset(guardianId: id, pose: pose);
  }

  Iterable<String> get poseAssets => guardianPoseAssets[id]!.values;

  static const all = <GuardianModel>[
    GuardianModel(
      id: GuardianId.crystal,
      name: 'Crystal',
      personality: 'Calme et rassurante',
      welcomeMessage: 'On avance tranquillement, à ton rythme.',
      color: 0xFF7967C7,
      idleAsset: AppAssets.guardianCrystalIdle,
    ),
    GuardianModel(
      id: GuardianId.pixel,
      name: 'Pixel',
      personality: 'Créatif et inventeur',
      welcomeMessage: 'Et si on inventait notre prochain petit pas ?',
      color: 0xFF2F80ED,
      idleAsset: AppAssets.guardianPixelIdle,
    ),
    GuardianModel(
      id: GuardianId.pyro,
      name: 'Pyro',
      personality: 'Courageux et protecteur',
      welcomeMessage: 'Je suis avec toi, un petit pas après l\'autre.',
      color: 0xFFE06A47,
      idleAsset: AppAssets.guardianPyroIdle,
    ),
    GuardianModel(
      id: GuardianId.gear,
      name: 'Gear',
      personality: 'Organisé et méthodique',
      welcomeMessage: 'Trouvons ensemble le prochain repère.',
      color: 0xFF557384,
      idleAsset: AppAssets.guardianGearIdle,
    ),
    GuardianModel(
      id: GuardianId.wave,
      name: 'Wave',
      personality: 'Doux et empathique',
      welcomeMessage: 'Prends ton temps, je reste près de toi.',
      color: 0xFF2A9D9F,
      idleAsset: AppAssets.guardianWaveIdle,
    ),
  ];

  static GuardianModel fromStorageId(
    String? value, {
    GuardianId fallback = GuardianId.crystal,
  }) {
    return all.firstWhere(
      (guardian) => guardian.storageId == value,
      orElse: () => all.firstWhere((guardian) => guardian.id == fallback),
    );
  }
}

class GuardianLifeCycle {
  const GuardianLifeCycle._();

  static GuardianActivity activityAt(DateTime now) {
    if (now.hour < 7 || now.hour >= 21) return GuardianActivity.sleeping;
    if (now.hour < 9) return GuardianActivity.wakingUp;
    if (now.hour >= 19) return GuardianActivity.resting;
    return now.hour.isEven
        ? GuardianActivity.reading
        : GuardianActivity.creating;
  }

  static String label(GuardianActivity activity) => switch (activity) {
    GuardianActivity.wakingUp => 'se prépare pour la journée',
    GuardianActivity.reading => 'lit tranquillement',
    GuardianActivity.creating => 'bricole une nouvelle idée',
    GuardianActivity.resting => 'se repose après sa journée',
    GuardianActivity.sleeping => 'dort paisiblement',
  };
}
