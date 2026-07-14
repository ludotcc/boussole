# Mémo – Découpage du Sprint 15

Ce document sert de référence de développement pour le Sprint 15.

L'objectif est de construire progressivement l'expérience enfant tout en limitant les régressions et en produisant les ressources graphiques uniquement lorsqu'elles deviennent réellement nécessaires.

---

# Sprint 15.1 — Les fondations de l'espace enfant

## Développement

- Modes d'appareil
  - Téléphone familial
  - Tablette personnelle
  - Tablette partagée
- Sélection du profil enfant
- PIN parent
- Protection des routes GoRouter
- Nouvelle navigation enfant
- Création de la Maison (version minimale)
- Intégration de **Ma journée** dans la Maison
- Préparation des Providers, Repositories et Services du Sprint 15

## Ressources graphiques

Aucun PNG définitif.

Utiliser uniquement des placeholders si nécessaire.

---

# Sprint 15.2 — Les Gardiens des Repères

## Développement

- Création des modèles des Gardiens
- Sélection d'un Gardien
- Changement de Gardien
- Personnalités
- Dialogues
- Cycle jour / nuit
- Présence du Gardien dans la Maison

## PNG à produire

- Crystal
- Pixel
- Pyro
- Gear
- Wave
- Expressions principales
- Activités principales

---

# Sprint 15.3 — La Maison

## Développement

- Maison vivante
- Pièces
- Ambiances
- Activités du Gardien
- Cycle matin / journée / soir / nuit
- Souvenirs
- Évolution de la Maison

## PNG à produire

- Maison
- Salon
- Cuisine
- Coin lecture
- Jardin
- Variantes jour
- Variantes nuit
- Objets fixes

---

# Sprint 15.4 — Les Éclats

## Développement

- Économie des Éclats
- Anti-triche
- Historique
- Solde
- Récompenses de journée
- Récompenses de routines importantes

## PNG à produire

- Icône Éclat
- Animation de gain
- Compteur
- Variantes visuelles

---

# Sprint 15.5 — Les Trouvailles

## Développement

- Catalogue
- Inventaire
- Achats
- Placement dans la Maison
- Raretés
- Catégories

## PNG à produire

- Mobilier
- Tapis
- Plantes
- Lampes
- Décorations
- Accessoires
- Objets rares
- Souvenirs

⚠️ C'est le plus gros travail graphique du Sprint 15.

---

# Sprint 15.6 — Le Moteur des Repères

## Développement

- Analyse du contexte
- Analyse de la journée
- Analyse des besoins
- Deux propositions
- Historique
- Personnalisation
- Gestion des émotions
- Centres d'intérêt

## PNG à produire

Quasiment aucun.

Réutilisation des illustrations existantes.

---

# Sprint 15.7 — Les Missions Secrètes

## Développement

- Génération des missions
- Validation parentale
- Récompenses
- Historique
- Intégration au Gardien

## PNG à produire

- Coffret Mission Secrète
- Cartes Mission
- Validation
- Célébration

---

# Sprint 15.8 — Les Moments Partagés

## Développement

- Catalogue
- Déclenchement
- Historique
- Intégration à la Maison

## PNG à produire

- Illustrations des différents Moments Partagés
- Icônes dédiées

---

# Sprint 15.9 — Finalisation de l'expérience enfant

## Développement

- Animations
- Dialogues
- Sons (si prévus)
- Accessibilité
- Optimisations
- Corrections UX
- Tests familiaux

## PNG à produire

Uniquement les ajustements découverts pendant les tests.

---

# Logique de développement

L'ordre des sprints permet de limiter les retours en arrière :

- ne pas dessiner les décorations avant que la Maison existe ;
- ne pas créer les objets avant que l'économie des Éclats soit prête ;
- ne pas produire les illustrations des Missions Secrètes avant que leur fonctionnement soit validé ;
- concentrer les gros travaux graphiques (Gardiens, Maison et Trouvailles) lorsque leur architecture est stabilisée afin d'éviter de refaire des PNG après des changements de conception.


assets/images/guardians/crystal/
  guardian_crystal_idle.png
  guardian_crystal_welcome.png
  guardian_crystal_talking.png
  guardian_crystal_choices.png
  guardian_crystal_encourage.png
  guardian_crystal_reassure.png
  guardian_crystal_celebrate.png
  guardian_crystal_sleeping.png

assets/images/guardians/pixel/
  guardian_pixel_idle.png
  guardian_pixel_welcome.png
  guardian_pixel_talking.png
  guardian_pixel_choices.png
  guardian_pixel_encourage.png
  guardian_pixel_reassure.png
  guardian_pixel_celebrate.png
  guardian_pixel_sleeping.png

assets/images/guardians/pyro/
  guardian_pyro_idle.png
  guardian_pyro_welcome.png
  guardian_pyro_talking.png
  guardian_pyro_choices.png
  guardian_pyro_encourage.png
  guardian_pyro_reassure.png
  guardian_pyro_celebrate.png
  guardian_pyro_sleeping.png

assets/images/guardians/gear/
  guardian_gear_idle.png
  guardian_gear_welcome.png
  guardian_gear_talking.png
  guardian_gear_choices.png
  guardian_gear_encourage.png
  guardian_gear_reassure.png
  guardian_gear_celebrate.png
  guardian_gear_sleeping.png

assets/images/guardians/wave/
  guardian_wave_idle.png
  guardian_wave_welcome.png
  guardian_wave_talking.png
  guardian_wave_choices.png
  guardian_wave_encourage.png
  guardian_wave_reassure.png
  guardian_wave_celebrate.png
  guardian_wave_sleeping.png