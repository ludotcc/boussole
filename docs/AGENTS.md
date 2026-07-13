# AGENTS.md
# Boussole – Règles d'intervention IA
Version : 2.0
Dernière mise à jour : 13 juillet 2026

## Mission

L'assistant est un membre permanent de l'équipe Boussole.

Son objectif est de faire avancer le projet tout en protégeant :

- la vision produit ;
- la qualité du code ;
- l'expérience utilisateur ;
- la cohérence de l'architecture.

---

## Priorité des sources

1. Demande explicite du propriétaire.
2. Code présent dans le dépôt.
3. Documentation Sprint concernée.
4. PROJECT_CONTEXT.md
5. PROJECT_STATUS.md
6. ROADMAP.md
7. DEVELOPMENT_RULES.md

---

## Avant toute intervention

Toujours :

- analyser l'existant ;
- réutiliser le code ;
- éviter les doublons ;
- respecter les décisions validées.

Ne jamais réécrire une architecture existante sans nécessité.

---

## Architecture officielle

Page

↓

Widget

↓

Riverpod Provider

↓

Repository

↓

Service

↓

Firebase / Firestore

---

## Philosophie produit

Toujours respecter :

- bienveillance ;
- autonomie ;
- simplicité ;
- encouragement ;
- confiance.

Ne jamais :

- culpabiliser ;
- comparer les enfants ;
- remplacer les parents ;
- créer une mécanique addictive.

---

## Sprint 15

Toute nouvelle fonctionnalité liée à l'enfant doit respecter les documents :

- SPRINT15_DESIGN.md
- DECISIONS.md
- GARDIENS.md
- MOTEUR_DES_REPERES.md
- MAISON.md
- ECONOMIE_ECLATS.md
- MISSIONS_SECRETES.md

Ils deviennent la référence officielle de l'expérience enfant.

---

## Développement

Privilégier :

- modifications locales ;
- fichiers existants ;
- code lisible ;
- composants réutilisables.

Toujours fournir un code complet lorsque cela est demandé.

---

## Vérifications

Après une modification importante :

- dart format
- flutter analyze
- tests existants

Signaler toute vérification impossible.

---

## Objectif

Chaque décision doit renforcer cette vision :

**Créer le meilleur compagnon numérique pour accompagner les enfants dans leur quotidien tout en renforçant les liens familiaux.**
