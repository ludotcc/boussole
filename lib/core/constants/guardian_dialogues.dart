import '../../models/guardian_experience_state.dart';
import '../../models/guardian_model.dart';

const guardianDialogues = <GuardianId, Map<GuardianPose, List<String>>>{
  GuardianId.crystal: {
    GuardianPose.welcome: [
      'Je suis heureuse de te retrouver.',
      'Bienvenue dans ta Maison.',
    ],
    GuardianPose.talking: [
      'Je suis contente de te voir.',
      'On avance tranquillement ?',
    ],
    GuardianPose.encourage: [
      'Chaque petit pas compte.',
      'Tu avances à ton rythme.',
    ],
    GuardianPose.reassure: [
      'Prends ton temps, je reste là.',
      'On peut respirer doucement.',
    ],
    GuardianPose.celebrate: [
      'Bravo pour tous tes petits pas !',
      'Tu peux être fier de toi.',
    ],
    GuardianPose.sleeping: ['Bonne nuit.', 'À demain, repose-toi bien.'],
    GuardianPose.choices: [''],
    GuardianPose.idle: ['Je suis là si tu as besoin de moi.'],
  },
  GuardianId.pixel: {
    GuardianPose.welcome: [
      'Te voilà ! Inventons une belle journée.',
      'Bienvenue, plein d’idées nous attendent.',
    ],
    GuardianPose.talking: [
      'Prêt à imaginer la suite ?',
      'J’ai peut-être une petite idée.',
    ],
    GuardianPose.encourage: [
      'Ton idée prend forme !',
      'Continue, c’est bien imaginé.',
    ],
    GuardianPose.reassure: [
      'On peut essayer autrement.',
      'Une pause aide parfois les idées.',
    ],
    GuardianPose.celebrate: [
      'Quelle belle création aujourd’hui !',
      'Tes petits pas ont fait des merveilles !',
    ],
    GuardianPose.sleeping: [
      'Bonne nuit, petit inventeur.',
      'Les idées se reposent aussi.',
    ],
    GuardianPose.choices: [''],
    GuardianPose.idle: ['Je prépare une nouvelle idée.'],
  },
  GuardianId.pyro: {
    GuardianPose.welcome: [
      'Content de te retrouver, aventurier !',
      'Une nouvelle journée commence.',
    ],
    GuardianPose.talking: ['Prêt pour aujourd’hui ?', 'Je suis avec toi.'],
    GuardianPose.encourage: [
      'Tu peux être fier de ton courage.',
      'Encore un petit pas, je suis là.',
    ],
    GuardianPose.reassure: [
      'Tu n’es pas seul.',
      'On peut avancer tout doucement.',
    ],
    GuardianPose.celebrate: [
      'Bravo, quel courage aujourd’hui !',
      'Mission de la journée accomplie !',
    ],
    GuardianPose.sleeping: [
      'Bonne nuit, repose tes forces.',
      'À demain, courageux compagnon.',
    ],
    GuardianPose.choices: [''],
    GuardianPose.idle: ['Je veille tranquillement.'],
  },
  GuardianId.gear: {
    GuardianPose.welcome: [
      'Tout est prêt pour cette journée.',
      'Heureux de te retrouver.',
    ],
    GuardianPose.talking: [
      'Trouvons le prochain repère.',
      'On regarde la suite ensemble ?',
    ],
    GuardianPose.encourage: [
      'Très bien, une étape après l’autre.',
      'Ton chemin devient plus clair.',
    ],
    GuardianPose.reassure: [
      'On peut reprendre depuis le début.',
      'Pas de souci, organisons-nous doucement.',
    ],
    GuardianPose.celebrate: [
      'Toutes ces étapes méritent un bravo !',
      'Journée bien menée !',
    ],
    GuardianPose.sleeping: [
      'Bonne nuit, tout peut attendre demain.',
      'Les rouages se reposent.',
    ],
    GuardianPose.choices: [''],
    GuardianPose.idle: ['Je range quelques idées.'],
  },
  GuardianId.wave: {
    GuardianPose.welcome: [
      'Je suis si doux de te retrouver.',
      'Bienvenue, prends ton temps.',
    ],
    GuardianPose.talking: [
      'Comment te sens-tu aujourd’hui ?',
      'Je suis là pour t’écouter.',
    ],
    GuardianPose.encourage: [
      'Tu avances merveilleusement bien.',
      'Chaque effort est précieux.',
    ],
    GuardianPose.reassure: [
      'Respire, tout va bien.',
      'On peut rester calme un instant.',
    ],
    GuardianPose.celebrate: [
      'Je suis très heureux pour toi !',
      'Tous tes petits pas brillent aujourd’hui.',
    ],
    GuardianPose.sleeping: [
      'Bonne nuit, fais de doux rêves.',
      'Repose-toi bien, à demain.',
    ],
    GuardianPose.choices: [''],
    GuardianPose.idle: ['Je profite du calme de la Maison.'],
  },
};

String guardianDialogue(
  GuardianId guardianId,
  GuardianPose pose, {
  int variant = 0,
}) {
  final phrases =
      guardianDialogues[guardianId]?[pose] ??
      guardianDialogues[GuardianId.crystal]![pose]!;
  return phrases[variant % phrases.length];
}
