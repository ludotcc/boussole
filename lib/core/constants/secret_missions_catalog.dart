import '../../models/secret_mission.dart';

class SecretMissionTemplate {
  const SecretMissionTemplate(
    this.id,
    this.title,
    this.description,
    this.category,
    this.reward,
    this.iconId,
  );
  final String id;
  final String title;
  final String description;
  final SecretMissionCategory category;
  final int reward;
  final String iconId;
}

const secretMissionsCatalog = <SecretMissionTemplate>[
  SecretMissionTemplate(
    'family_drawing',
    'Un dessin surprise',
    'Fais un dessin pour quelqu’un de ta famille.',
    SecretMissionCategory.family,
    8,
    'palette',
  ),
  SecretMissionTemplate(
    'family_thanks',
    'Un joli merci',
    'Dis merci à une personne pour quelque chose qui t’a fait plaisir.',
    SecretMissionCategory.emotions,
    5,
    'favorite',
  ),
  SecretMissionTemplate(
    'family_table',
    'Coup de main secret',
    'Aide à préparer la table sans qu’on te le demande.',
    SecretMissionCategory.helping,
    8,
    'table',
  ),
  SecretMissionTemplate(
    'nature_plant',
    'Gardien de la plante',
    'Arrose une plante avec l’accord d’un parent.',
    SecretMissionCategory.nature,
    6,
    'plant',
  ),
  SecretMissionTemplate(
    'help_tidy',
    'Petit rangement surprise',
    'Range une chose qui aidera toute la famille.',
    SecretMissionCategory.helping,
    8,
    'tidy',
  ),
  SecretMissionTemplate(
    'emotion_hug',
    'Un câlin cadeau',
    'Propose un câlin à quelqu’un qui en a envie.',
    SecretMissionCategory.emotions,
    5,
    'favorite',
  ),
  SecretMissionTemplate(
    'kind_words',
    'Trois mots gentils',
    'Dis trois choses gentilles à une personne.',
    SecretMissionCategory.emotions,
    7,
    'chat',
  ),
  SecretMissionTemplate(
    'create_together',
    'Construire ensemble',
    'Construis quelque chose avec une personne de ta famille.',
    SecretMissionCategory.creativity,
    10,
    'build',
  ),
  SecretMissionTemplate(
    'nature_birds',
    'Explorateur des oiseaux',
    'Observe les oiseaux quelques minutes avec quelqu’un.',
    SecretMissionCategory.nature,
    7,
    'nature',
  ),
  SecretMissionTemplate(
    'family_surprise',
    'Petite surprise',
    'Prépare une petite surprise avec l’aide d’un adulte.',
    SecretMissionCategory.family,
    12,
    'gift',
  ),
  SecretMissionTemplate(
    'courage_try',
    'Un pas courageux',
    'Essaie une petite chose qui te semblait difficile.',
    SecretMissionCategory.courage,
    10,
    'courage',
  ),
  SecretMissionTemplate(
    'help_someone',
    'Main tendue',
    'Demande à quelqu’un si tu peux lui donner un coup de main.',
    SecretMissionCategory.helping,
    8,
    'help',
  ),
];

SecretMissionTemplate missionTemplate(String id) =>
    secretMissionsCatalog.firstWhere((item) => item.id == id);
