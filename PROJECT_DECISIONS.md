# PROJECT_DECISIONS.md

# Décisions officielles du projet Boussole

Version : 1.0

Ce document regroupe les décisions permanentes du projet.

Il constitue la référence principale avant toute conception ou tout développement.

En cas de conflit :

PROJECT_DECISIONS.md prévaut sur les documents des Sprints.

---

# Mission de Boussole

Boussole aide les enfants à gagner progressivement en autonomie grâce à des routines positives et un Compagnon bienveillant.

Les parents préparent le cadre.

Les enfants vivent l'expérience.

Le Compagnon accompagne.

---

# Philosophie

Le projet repose sur cinq valeurs.

- Bienveillance
- Simplicité
- Autonomie
- Encouragement
- Confiance

Le projet ne doit jamais :

- culpabiliser ;
- comparer les enfants ;
- générer du stress ;
- remplacer les parents.

---

# Les parents

Les parents restent toujours les décideurs.

Ils :

- créent le cadre ;
- définissent les règles ;
- valident les informations importantes ;
- gardent le contrôle de l'application.

Le Compagnon ne remplace jamais les parents.

---

# Le Compagnon

Le Compagnon :

- accompagne ;
- encourage ;
- propose ;
- rassure ;
- célèbre les beaux comportements ;
- apprend progressivement.

Le Compagnon ne doit jamais :

- donner des ordres ;
- juger ;
- punir ;
- culpabiliser ;
- comparer ;
- manipuler.

---

# Intelligence Artificielle

Le projet n'utilise aucune Intelligence Artificielle.

Interdictions :

- chatbot
- génération de contenu
- génération de texte
- recherche Internet
- diagnostic
- analyse comportementale

Le Compagnon fonctionne uniquement grâce à des règles fonctionnelles.

---

# Vie privée

Le Compagnon connaît uniquement :

- les informations renseignées volontairement par les parents ;
- les informations déjà présentes dans Boussole ;
- les habitudes observées dans l'application.

Aucune autre source n'est autorisée.

---

# Mémoire

La mémoire du Compagnon :

- est positive ;
- est évolutive ;
- est limitée ;
- est utile ;
- représente une habitude.

Toute nouvelle mémoire doit être validée par un parent.

---

# Enfant

L'espace enfant ne comporte jamais de saisie clavier.

Toutes les interactions utilisent :

- boutons ;
- cartes ;
- icônes ;
- sélections visuelles.

L'enfant choisit.

Il n'écrit jamais.

---

# Dialogues

Le Compagnon :

- propose ;
- accompagne ;
- encourage.

Il ne donne jamais d'ordre.

Toutes les phrases doivent être :

- courtes ;
- positives ;
- simples ;
- adaptées à l'âge de l'enfant.

---

# Expérience utilisateur

Chaque écran doit répondre à au moins un de ces objectifs :

- aider l'enfant ;
- rassurer ;
- encourager ;
- développer l'autonomie ;
- favoriser un beau moment.

Toute fonctionnalité qui ne répond à aucun de ces objectifs doit être remise en question.

---

# Récompenses

Les récompenses servent à encourager.

Jamais à créer une dépendance.

Le projet évite :

- les récompenses permanentes ;
- les mécanismes addictifs ;
- les obligations quotidiennes.

---

# Activités

Le Compagnon ne propose jamais une simple activité.

Il propose toujours un moment à vivre.

Les propositions doivent être :

- concrètes ;
- réalisables ;
- adaptées au contexte.

Le monde réel est privilégié lorsqu'il est pertinent.

Les activités sur écran ne sont jamais dévalorisées.

---

# Architecture officielle

Architecture obligatoire :

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

Aucune nouvelle architecture ne doit être créée sans validation.

---

# Développement

Avant toute modification :

- analyser l'existant ;
- réutiliser le code existant ;
- éviter les doublons ;
- préserver les fonctionnalités existantes ;
- respecter les documents du projet.

---

# Documentation

Les décisions permanentes sont stockées dans :

PROJECT_DECISIONS.md

Les décisions d'un Sprint sont stockées dans :

SprintXX/

Les documents des Sprints ne modifient jamais les décisions permanentes.

---

# Priorité des documents

Ordre officiel :

1. AGENTS.md
2. PROJECT_DECISIONS.md
3. PROJECT_CONTEXT.md
4. PROJECT_STATUS.md
5. Sprint en cours
6. Documentation technique

Cet ordre est obligatoire.

---

# Règles de développement

Toute nouvelle fonctionnalité doit respecter les conditions suivantes.

✓ respecte la philosophie

✓ respecte les parents

✓ respecte l'enfant

✓ respecte la vie privée

✓ reste simple

✓ améliore réellement l'expérience

✓ n'utilise aucune IA

✓ respecte l'architecture officielle

✓ évite la dette technique

✓ reste cohérente avec le projet

Si une réponse est NON,

la fonctionnalité doit être revue avant son développement.

---

# Vision

Le succès de Boussole ne sera pas mesuré par le temps passé dans l'application.

Le succès sera mesuré par les beaux moments vécus par les enfants en dehors de l'écran.

Le Compagnon n'a jamais pour objectif que l'enfant utilise Boussole.

Le Compagnon a toujours pour objectif que l'enfant vive un beau moment.

Cette règle guide toutes les décisions du projet.