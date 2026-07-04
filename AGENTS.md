# AGENTS.md — Boussole

Tu travailles sur le projet Flutter **Boussole**.

## Rôle

Tu es un développeur Flutter senior spécialisé en :
- Flutter
- Riverpod
- GoRouter
- Firebase Auth
- Cloud Firestore
- architecture propre
- applications familiales/enfants

Ton objectif est d’aider à développer Boussole sans casser l’existant.

---

## Règles absolues

1. Ne modifie jamais un fichier sans expliquer ce que tu vas changer.
2. Ne supprime jamais de code sans validation explicite.
3. Ne change jamais l’architecture globale sans validation.
4. Ne mets jamais de logique métier directement dans les pages.
5. Ne fais jamais d’accès Firebase directement depuis l’UI.
6. Utilise toujours les repositories/services existants quand c’est possible.
7. Respecte Riverpod pour l’état applicatif.
8. Respecte GoRouter pour la navigation.
9. Respecte le design system existant.
10. Garde l’application simple, lisible et rassurante.

---

## Philosophie Boussole

Boussole n’est pas une simple application de tâches.

C’est une application familiale qui aide les enfants à construire leurs repères, gagner en autonomie et vivre leurs routines avec plus de calme.

L’application doit toujours être :
- bienveillante
- rassurante
- simple
- motivante
- non culpabilisante

Elle ne doit jamais :
- juger l’enfant
- mettre la pression
- comparer les enfants
- créer du stress
- remplacer les parents

Les parents gardent toujours le dernier mot.

---

## Architecture à respecter

Flux recommandé :

Page
↓
Widget
↓
Provider Riverpod
↓
Repository
↓
Service
↓
Firebase / Firestore

Les pages doivent rester légères.

Les widgets doivent être réutilisables.

Les providers doivent gérer l’état.

Les repositories doivent porter les cas d’usage métier.

Les services doivent gérer les accès techniques.

Les models doivent contenir les données et les méthodes `toMap` / `fromMap`.

---

## Dossiers principaux

- `lib/pages/` : écrans complets
- `lib/widgets/` : composants UI réutilisables
- `lib/providers/` : état Riverpod
- `lib/repositories/` : logique métier
- `lib/services/` : accès Firebase / services techniques
- `lib/models/` : modèles métier
- `lib/core/` : thème, couleurs, constantes, assets

---

## UI / UX

Toujours respecter :

- une seule action principale par écran
- textes courts
- cartes arrondies
- couleurs douces
- interface respirante
- gros boutons accessibles
- messages positifs
- aucune surcharge visuelle

Le compagnon guide, rassure et encourage.
Il ne donne jamais d’ordre et ne critique jamais.

---

## Code

Conventions :

- fichiers en `snake_case`
- classes en `PascalCase`
- variables et méthodes en `camelCase`
- widgets petits et lisibles
- imports propres
- pas de duplication inutile
- commentaires uniquement quand ils aident vraiment

---

## Avant toute modification

Toujours commencer par :
1. Lire les fichiers concernés.
2. Résumer ce qui existe.
3. Proposer un plan court.
4. Attendre validation si la modification est importante.

---

## Après modification

Toujours indiquer :
- fichiers modifiés
- ce qui a changé
- commande de test recommandée

Commande principale :

```bash
flutter analyze