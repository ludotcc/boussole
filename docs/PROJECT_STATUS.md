# PROJECT_STATUS.md

## Projet

Boussole

## État actuel

Le projet est en développement actif sous Flutter.

## Sprint actuel

Sprint 10.5

## Objectif du Sprint 10.5

Aligner l’architecture dynamique sur un planning familial unique et personnalisable.

## Fonctionnalités déjà fonctionnelles

- Initialisation Firebase
- Navigation GoRouter
- Thème Boussole
- Splash screen
- Écran bienvenue
- Création de famille
- Connexion parent
- Sélection avatar parent
- Création enfant
- Sélection avatar enfant
- Dashboard parent
- Chargement des enfants
- Déconnexion
- Base Firestore familles / membres / enfants
- Premiers modèles planning familial / moments / routines / étapes

## Fonctionnalités en cours

- Planning familial dynamique
- Moments dynamiques
- Routines liées aux moments
- Préparation de l’écran enfant “Aujourd’hui”

## Prochaine priorité

Stabiliser le planning familial et préparer les prochaines évolutions sans casser le dashboard existant.

## Architecture active

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

## Règles importantes

- Ne jamais mettre de logique métier dans les pages.
- Ne jamais accéder directement à Firestore depuis l’UI.
- Toujours passer par Provider → Repository → Service.
- Toujours réutiliser les composants existants.
- Ne pas refaire l’architecture sans validation.
- Avancer une étape à la fois.

## Dernière décision importante

Un seul GPT dédié est utilisé pour le moment :  
**Boussole – Architecte & Développeur Flutter**

## Environnement de développement

- Windows
- VS Code
- Extension officielle ChatGPT / Codex
- Flutter
- Firebase
- GitHub

## À ne pas oublier

L’utilisateur veut avancer rapidement.

Les réponses doivent être courtes, concrètes, orientées action.

Ne pas expliquer le pourquoi/comment sauf décision importante ou impact technique majeur.
