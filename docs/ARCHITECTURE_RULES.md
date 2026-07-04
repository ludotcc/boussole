# ARCHITECTURE_RULES.md

# Architecture officielle de Boussole

Ce document est la référence absolue.

Toute nouvelle fonctionnalité doit respecter ces règles.

---

# Principe n°1

Ne jamais casser une architecture existante.

Toujours s'intégrer à l'existant.

---

# Principe n°2

Une responsabilité = un fichier.

Éviter les fichiers "fourre-tout".

---

# Principe n°3

Une page ne contient jamais de logique métier.

Une page :

- affiche
- appelle un provider
- gère l'affichage

Rien d'autre.

---

# Principe n°4

Les Providers

Ils :

- exposent l'état
- déclenchent les actions

Ils ne connaissent pas Firestore.

---

# Principe n°5

Les Repositories

Ils contiennent les cas d'usage métier.

Ils orchestrent les services.

Ils sont le cœur fonctionnel.

---

# Principe n°6

Les Services

Ils dialoguent avec :

- Firebase
- Firestore
- Storage
- API

Ils ne contiennent pas de logique fonctionnelle.

---

# Principe n°7

Les Models

Ils représentent uniquement les données.

Ils possèdent :

- toMap()
- fromMap()

Ils ne connaissent pas Flutter.

---

# Principe n°8

Les Widgets

Toujours petits.

Toujours réutilisables.

Jamais de logique métier.

---

# Principe n°9

Les Pages

Une page = une responsabilité.

Une page ne dépasse idéalement pas 300 lignes.

Si elle devient trop grande :

→ créer des widgets.

---

# Principe n°10

Ne jamais accéder directement à Firestore depuis :

- une page
- un widget

Toujours passer par :

Repository

↓

Service

↓

Firestore

---

# Principe n°11

Toujours privilégier :

Lisibilité

avant

Performance prématurée.

---

# Principe n°12

Une nouvelle fonctionnalité doit :

- respecter l'existant
- être facilement testable
- être réutilisable
- être documentée si nécessaire

---

# Principe n°13

Avant de coder :

Lire.

Comprendre.

Proposer.

Puis seulement développer.

---

# Principe n°14

Ne jamais modifier plusieurs systèmes différents si une solution plus simple existe.

---

# Principe n°15

Toujours réfléchir à l'impact sur :

- les parents
- les enfants
- l'expérience utilisateur
- les performances
- la maintenabilité

---

# Philosophie

Le meilleur code est celui qui sera encore agréable à maintenir dans 5 ans.