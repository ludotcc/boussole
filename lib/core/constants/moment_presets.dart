import '../app_assets.dart';

class MomentPreset {
  const MomentPreset({
    required this.key,
    required this.name,
    required this.iconKey,
    required this.image,
    this.orderMinutes,
    this.hasRoutine = false,
    this.requiresCustomName = false,
  });

  final String key;
  final String name;
  final String iconKey;
  final String image;
  final int? orderMinutes;
  final bool hasRoutine;
  final bool requiresCustomName;
}

const momentPresets = <MomentPreset>[
  MomentPreset(
    key: 'routine_morning',
    name: 'Rituel du matin',
    iconKey: 'routineMorning',
    image: AppAssets.routineMorning,
    hasRoutine: true,
  ),
  MomentPreset(
    key: 'breakfast',
    name: 'Petit-déjeuner',
    iconKey: 'breakfast',
    image: AppAssets.breakfast,
    orderMinutes: 8 * 60,
  ),
  MomentPreset(
    key: 'lunch',
    name: 'Déjeuner',
    iconKey: 'lunch',
    image: AppAssets.lunch,
    orderMinutes: 12 * 60,
  ),
  MomentPreset(
    key: 'school',
    name: 'Devoirs',
    iconKey: 'homework',
    image: AppAssets.homework,
  ),
  MomentPreset(
    key: 'school_bag',
    name: 'École',
    iconKey: 'school_bag',
    image: AppAssets.schoolBag,
  ),
  MomentPreset(
    key: 'leisure',
    name: 'Temps libre',
    iconKey: 'videoGames',
    image: AppAssets.freeTime,
  ),
  MomentPreset(
    key: 'video_games',
    name: 'Jeux vidéo',
    iconKey: 'video_games',
    image: AppAssets.videoGames,
  ),
  MomentPreset(
    key: 'routine_evening',
    name: 'Rituel du soir',
    iconKey: 'routineEvening',
    image: AppAssets.routineEvening,
    hasRoutine: true,
  ),
  MomentPreset(
    key: 'bike',
    name: 'Vélo',
    iconKey: 'bike',
    image: AppAssets.bike,
  ),
  MomentPreset(
    key: 'family_care',
    name: 'S’occuper de la famille',
    iconKey: 'family_care',
    image: AppAssets.familyCare,
  ),
  MomentPreset(
    key: 'brush_teeth',
    name: 'Brosser ses dents',
    iconKey: 'brush_teeth',
    image: AppAssets.brushTeeth,
  ),
  MomentPreset(
    key: 'shopping',
    name: 'Courses',
    iconKey: 'shopping',
    image: AppAssets.shopping,
  ),
  MomentPreset(
    key: 'dinner',
    name: 'Dîner',
    iconKey: 'dinner',
    image: AppAssets.dinner,
    orderMinutes: 19 * 60,
  ),
  MomentPreset(
    key: 'medication',
    name: 'Prendre ses médicaments',
    iconKey: 'medication',
    image: AppAssets.medication,
  ),
  MomentPreset(
    key: 'swimming',
    name: 'Piscine',
    iconKey: 'swimming',
    image: AppAssets.swimming,
  ),
  MomentPreset(
    key: 'screen_time',
    name: 'Temps d’écran',
    iconKey: 'screen_time',
    image: AppAssets.screenTime,
  ),
  MomentPreset(
    key: 'wake_up',
    name: 'Je suis réveillé',
    iconKey: 'wake_up',
    image: AppAssets.wakeUp,
    orderMinutes: 7 * 60,
  ),
  MomentPreset(
    key: 'sleep',
    name: 'Je vais dormir',
    iconKey: 'sleep',
    image: AppAssets.sleep,
    orderMinutes: 22 * 60,
  ),
  MomentPreset(
    key: 'nap',
    name: 'Petite sieste',
    iconKey: 'nap',
    image: AppAssets.nap,
  ),
  MomentPreset(
    key: 'divers',
    name: 'Divers',
    iconKey: 'divers',
    image: AppAssets.divers,
    requiresCustomName: true,
  ),
  MomentPreset(
    key: 'household_tasks',
    name: 'Tâches ménagères',
    iconKey: 'householdTasks',
    image: AppAssets.householdTasks,
  ),
  MomentPreset(
    key: 'shower',
    name: 'Douche',
    iconKey: 'bath',
    image: AppAssets.bath,
  ),
];

const initialChildPlanningPresetKeys = <String>[
  'wake_up',
  'breakfast',
  'lunch',
  'dinner',
  'sleep',
];

MomentPreset momentPresetByKey(String key) {
  return momentPresets.firstWhere(
    (preset) => preset.key == key,
    orElse: () => throw ArgumentError.value(key, 'key', 'Preset inconnu'),
  );
}
