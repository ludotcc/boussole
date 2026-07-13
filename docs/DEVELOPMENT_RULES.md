# DEVELOPMENT_RULES.md
# Règles officielles de développement
Version : 2.0
Dernière mise à jour : 13 juillet 2026

---

# Objectif

Ces règles garantissent la cohérence, la qualité et la maintenabilité du projet Boussole.

Chaque développement doit respecter la vision produit avant toute considération technique.

---

# Méthode de travail

Avant toute modification :

1. Lire la demande.
2. Consulter la documentation concernée.
3. Réutiliser le code existant.
4. Limiter le périmètre des modifications.
5. Préserver les fonctionnalités existantes.

---

# Architecture

Architecture officielle :

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

Aucun accès direct à Firestore depuis une page ou un widget.

---

# Principes de développement

Toujours privilégier :

- simplicité ;
- lisibilité ;
- réutilisation ;
- performances ;
- évolutivité.

Ne jamais créer une nouvelle architecture lorsqu'une architecture existe déjà.

---

# Code

- fichiers en snake_case ;
- classes en PascalCase ;
- variables en camelCase ;
- imports propres ;
- widgets réutilisables ;
- commentaires uniquement lorsqu'ils apportent une réelle valeur.

---

# Documentation

Toute fonctionnalité importante doit être documentée.

Le Sprint 15 possède sa propre documentation de référence.

En cas de conflit, les documents du Sprint 15 priment sur une ancienne documentation fonctionnelle.

---

# Qualité

Après une modification Dart :

- lancer `dart format` sur les fichiers modifiés ;
- lancer `flutter analyze` lorsque plusieurs couches sont impactées ;
- exécuter les tests existants si disponibles ;
- vérifier les parcours modifiés.

---

# Dépendances

Aucune dépendance ne doit être ajoutée ou supprimée sans validation.

Éviter toute dette technique inutile.

---

# Interface

Respecter :

- le thème officiel ;
- les composants existants ;
- l'identité graphique de Boussole.

L'espace enfant et l'espace parent doivent conserver des expériences distinctes.

---

# Philosophie

Chaque développement doit renforcer au moins un de ces objectifs :

- favoriser l'autonomie ;
- réduire la charge mentale des parents ;
- créer des souvenirs familiaux ;
- renforcer la relation entre l'enfant et son Gardien.

Si une fonctionnalité ne répond à aucun de ces objectifs, elle doit être repensée.

---

# Vision finale

Le code doit rester suffisamment propre pour permettre au projet d'évoluer pendant plusieurs années sans remettre en cause ses fondations.
