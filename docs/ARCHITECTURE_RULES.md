# ARCHITECTURE_RULES.md
# Architecture officielle de Boussole
Version : 2.0
Dernière mise à jour : 13 juillet 2026

---

# Vision

L'architecture de Boussole est conçue pour rester simple, évolutive et maintenable.

Chaque couche possède une responsabilité unique.

Aucune logique métier ne doit être placée dans les pages.

---

# Architecture officielle

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

Les dépendances descendent toujours dans ce sens.

---

# Responsabilités

## Pages

- affichage ;
- navigation ;
- saisie utilisateur.

Aucune logique métier.

## Widgets

- composants réutilisables ;
- animations ;
- logique d'interface locale.

## Providers

- état ;
- chargement ;
- erreurs ;
- orchestration des actions.

## Repositories

- logique métier ;
- validation ;
- coordination des services.

## Services

- Firebase ;
- Firestore ;
- Authentification ;
- stockage local ;
- accès techniques.

## Models

- données ;
- sérialisation ;
- désérialisation.

---

# Architecture métier du Sprint 15

Le Sprint 15 ajoute une couche fonctionnelle sans modifier l'architecture technique.

Les nouveaux domaines métier sont :

- Gardiens des Repères
- Maison
- Économie des Éclats
- Missions Secrètes
- Moteur des Repères
- Modes d'appareil

Ces domaines restent implémentés via les repositories et providers existants ou futurs.

---

# Flux du Gardien

Profil enfant

↓

Moteur des Repères

↓

GuardianRepository

↓

GuardianService

↓

Firestore

Le Gardien n'exécute jamais directement de logique métier.

Toutes les décisions passent par le Moteur des Repères.

---

# Repositories prévus

Le projet pourra accueillir progressivement :

- GuardianRepository
- HouseRepository
- RewardsRepository
- MissionRepository
- ChildProfileRepository

Uniquement lorsqu'un domaine deviendra suffisamment important.

---

# Navigation

GoRouter reste le routeur officiel.

Les espaces Parent et Enfant doivent rester clairement séparés.

Le mode d'appareil décide de l'expérience affichée :

- Téléphone familial
- Tablette personnelle enfant
- Tablette partagée

---

# Firebase

Aucun accès direct à Firestore depuis :

- une Page ;
- un Widget ;
- un Provider.

Toutes les écritures transitent par un Repository puis un Service.

---

# Principes

Toujours :

- privilégier la réutilisation ;
- limiter les dépendances ;
- séparer présentation et métier ;
- conserver une architecture lisible.

Ne jamais :

- dupliquer une logique métier ;
- contourner un Repository ;
- accéder directement à Firestore depuis l'interface.

---

# Évolutivité

L'architecture est pensée pour accueillir :

- de nouveaux Gardiens ;
- une IA d'accompagnement ;
- de nouvelles Maisons ;
- de nouvelles économies ;
- de nouveaux domaines fonctionnels.

Sans remettre en cause les fondations existantes.

---

# Objectif

L'architecture doit permettre à Boussole d'évoluer pendant plusieurs années tout en restant simple à maintenir, cohérente et compréhensible pour toute personne rejoignant le projet.
