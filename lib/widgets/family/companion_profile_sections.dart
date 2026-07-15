import 'package:flutter/material.dart';

import '../../core/app_text_styles.dart';
import '../../models/child_companion_profile.dart';
import '../common/app_card.dart';

class CompanionProfileSections extends StatelessWidget {
  const CompanionProfileSections({
    super.key,
    required this.profile,
    required this.enabled,
    required this.onChanged,
  });

  final ChildCompanionProfile profile;
  final bool enabled;
  final ValueChanged<ChildCompanionProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profil du Compagnon', style: AppTextStyles.cardTitle),
          const SizedBox(height: 6),
          const Text(
            'Ces informations aident le Compagnon à mieux accompagner votre enfant.',
          ),
          const SizedBox(height: 20),
          _choices(
            title: 'Centres d’intérêt',
            question: 'Qu’est-ce qui fait généralement briller ses yeux ?',
            options: companionInterestOptions,
            selected: profile.interests,
            onChanged: (values) => _update(interests: values),
          ),
          _choices(
            title: 'Activités appréciées',
            question: 'Quelles activités aime-t-il généralement faire ?',
            options: companionLikedActivityOptions,
            selected: profile.likedActivities,
            onChanged: (values) => _update(likedActivities: values),
          ),
          _choices(
            title: 'Activités à éviter',
            question: 'Quelles activités préfère-t-il généralement éviter ?',
            options: companionAvoidedActivityOptions,
            selected: profile.activitiesToAvoid,
            onChanged: (values) => _update(activitiesToAvoid: values),
          ),
          _choices(
            title: 'Ce qui aide souvent',
            question: 'Lorsqu’un moment est difficile, qu’est-ce qui aide ?',
            options: companionHelpfulApproachOptions,
            selected: profile.helpfulApproaches,
            onChanged: (values) => _update(helpfulApproaches: values),
          ),
          _choices(
            title: 'Situations parfois difficiles',
            question: 'Quels moments demandent parfois plus d’accompagnement ?',
            options: companionDifficultSituationOptions,
            selected: profile.difficultSituations,
            onChanged: (values) => _update(difficultSituations: values),
          ),
          _choices(
            title: 'Objectifs des parents',
            question:
                'Dans quels domaines souhaitez-vous surtout l’accompagner ?',
            options: companionParentGoalOptions,
            selected: profile.parentGoals,
            maximum: 3,
            onChanged: (values) => _update(parentGoals: values),
          ),
          _choices(
            title: 'Besoins particuliers',
            question: 'Souhaitez-vous partager une information importante ?',
            options: companionSpecialNeedOptions,
            selected: profile.specialNeeds,
            onChanged: (values) => _update(
              specialNeeds: values,
              sensitiveSituations: values.isEmpty
                  ? const []
                  : profile.sensitiveSituations,
            ),
          ),
          if (profile.specialNeeds.isNotEmpty)
            _choices(
              title: 'Situations sensibles',
              question: 'Quelles situations sont parfois sensibles ?',
              options: companionSensitiveSituationOptions,
              selected: profile.sensitiveSituations,
              onChanged: (values) => _update(sensitiveSituations: values),
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _choices({
    required String title,
    required String question,
    required List<String> options,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
    int? maximum,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(question),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                FilterChip(
                  label: Text(option),
                  selected: selected.contains(option),
                  onSelected: !enabled
                      ? null
                      : (isSelected) {
                          if (isSelected) {
                            if (maximum != null && selected.length >= maximum) {
                              return;
                            }
                            onChanged([...selected, option]);
                          } else {
                            onChanged(
                              selected
                                  .where((value) => value != option)
                                  .toList(),
                            );
                          }
                        },
                ),
            ],
          ),
          if (maximum != null) ...[
            const SizedBox(height: 6),
            Text('${selected.length}/$maximum choix'),
          ],
        ],
      ),
    );
  }

  void _update({
    List<String>? interests,
    List<String>? likedActivities,
    List<String>? helpfulApproaches,
    List<String>? difficultSituations,
    List<String>? parentGoals,
    List<String>? specialNeeds,
    List<String>? sensitiveSituations,
    List<String>? activitiesToAvoid,
  }) {
    onChanged(
      ChildCompanionProfile(
        interests: interests ?? profile.interests,
        likedActivities: likedActivities ?? profile.likedActivities,
        helpfulApproaches: helpfulApproaches ?? profile.helpfulApproaches,
        difficultSituations: difficultSituations ?? profile.difficultSituations,
        parentGoals: parentGoals ?? profile.parentGoals,
        specialNeeds: specialNeeds ?? profile.specialNeeds,
        sensitiveSituations: sensitiveSituations ?? profile.sensitiveSituations,
        activitiesToAvoid: activitiesToAvoid ?? profile.activitiesToAvoid,
      ),
    );
  }
}

const companionInterestOptions = [
  'animaux',
  'dinosaures',
  'espace',
  'nature',
  'dragons',
  'pirates',
  'princesses',
  'voitures',
  'trains',
  'dessin',
  'musique',
  'danse',
  'cuisine',
  'bricolage',
  'construction',
  'Lego',
  'sciences',
  'lecture',
  'sport',
  'jardin',
  'jeux de société',
];
const companionLikedActivityOptions = [
  'construire',
  'dessiner',
  'colorier',
  'lire',
  'inventer des histoires',
  'cuisiner',
  'bricoler',
  'jardiner',
  'observer la nature',
  'observer les animaux',
  'faire du sport',
  'danser',
  'chanter',
  'jeux imaginaires',
  'jeux calmes',
  'jeux de réflexion',
  'aider à la maison',
];
const companionHelpfulApproachOptions = [
  'recevoir un câlin',
  'rester seul quelques minutes',
  'dessiner',
  'lire',
  'bouger',
  'parler',
  'respirer calmement',
  'écouter de la musique',
  'sortir',
  'jouer',
  'boire un verre d’eau',
];
const companionDifficultSituationOptions = [
  'devoirs',
  'courses',
  'repas',
  'coucher',
  'réveil',
  'transitions',
  'trajets',
  'salle d’attente',
  'changements',
  'séparations',
  'nouvelles situations',
];
const companionParentGoalOptions = [
  'autonomie',
  'confiance',
  'patience',
  'courage',
  'gestion des émotions',
  'concentration',
  'créativité',
  'responsabilités',
  'organisation',
  'entraide',
  'curiosité',
];
const companionSpecialNeedOptions = [
  'TSA',
  'TDAH',
  'TOP',
  'Dys...',
  'Hypersensibilité',
  'Handicap',
];
const companionSensitiveSituationOptions = [
  'bruit important',
  'foule',
  'attente',
  'changement imprévu',
  'nouveaux lieux',
  'nouvelles personnes',
  'lumière forte',
  'odeurs',
  'déplacements',
  'alimentation',
  'vêtements',
];
const companionAvoidedActivityOptions = [
  'dessin',
  'lecture',
  'cuisine',
  'musique',
  'bricolage',
  'activités sportives',
  'activités salissantes',
  'animaux',
  'nature',
];
