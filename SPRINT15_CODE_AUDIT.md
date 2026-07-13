# Audit technique avant Sprint 15 — Boussole

Date de l'audit : 14 juillet 2026  
Périmètre : dépôt Flutter ouvert dans `C:\Users\Ludo\boussole`  
Principe de lecture : le code présent dans le dépôt prime sur les documents lorsqu'il est plus récent.  
Nature de l'intervention : audit en lecture seule ; aucune migration et aucune mise à jour de dépendance.

## 1. Résumé exécutif

Le dépôt compile statiquement : `flutter analyze` termine avec **0 problème**. Cette réussite ne signifie toutefois pas que le socle est prêt à recevoir directement toutes les mécaniques du Sprint 15. Le code actuel est une application familiale fonctionnelle centrée sur l'organisation parent, le planning, les routines et « Ma journée ». L'expérience enfant Sprint 15 n'est pas encore implémentée : aucun modèle, provider, repository, service, écran ou asset dédié aux Gardiens, à la Maison, aux Éclats, aux Trouvailles, au Moteur des Repères, aux Missions Secrètes ou aux modes d'appareil n'existe.

Verdict : **Sprint 15.1 peut démarrer, mais uniquement comme sprint de fondation et de sécurisation de navigation**. Il ne faut pas greffer les nouveaux domaines dans `FamilyRepository` ou `FirestoreService`, déjà trop volumineux. « Ma journée » doit être conservée et encapsulée dans le nouvel espace enfant ; la page d'accueil enfant actuelle n'est pas `TodayPage`, mais une absence d'accueil autonome, puisque les cartes enfant du tableau de bord parent ouvrent directement `/today`.

Constats prioritaires :

- **Critique — aucune règle Firestore ou Storage n'est présente ou référencée** par `firebase.json`. Tout niveau réel d'isolation familiale dépend donc d'une configuration distante non versionnée et invérifiable.
- **Critique pour l'anti-triche — aucune primitive d'Éclats ni registre idempotent n'existe**. Le document de progression quotidienne est réinscriptible et réinitialisable ; il ne doit jamais devenir la source de vérité des récompenses.
- **Élevé — aucune garde GoRouter** : toutes les routes parent/enfant sont plates, sans `redirect`, sans distinction de mode d'appareil et sans verrou PIN. Un enfant peut revenir vers `/home` depuis l'écran de fin de journée.
- **Élevé — concurrence non maîtrisée** : `ChildDayProgressModel` est sauvegardé par remplacement complet du document. Deux appareils peuvent écraser leurs changements respectifs.
- **Élevé — écritures métier multi-documents non atomiques** : création de famille, initialisation d'un enfant, création/duplication de moments et routines, et synchronisation de certains événements personnels/familiaux.
- **Élevé — absence de tests Dart/Flutter** : le dossier `test/` n'existe pas. Les seuls tests natifs sont les squelettes générés par Flutter.
- **Élevé — dette de taille** : `FamilyRepository` fait 1 947 lignes, `FirestoreService` 925, `TodayPage` 1 242, et plusieurs pages/widgets dépassent 500 lignes.
- **Moyen — deux systèmes de thème et deux classes `BoussoleApp` coexistent**, avec des fichiers morts et cinq services Firestore modulaires inutilisés.
- **Moyen — assets très lourds** : environ 124,13 Mo d'images déclarées comme bundle, sans aucun asset Gardien/Maison/Éclat. Quatre chemins d'assets référencés sont absents.

Recommandation de séquencement : sécuriser le bootstrap, les modes d'appareil, la séparation des routes et le verrou parent en 15.1 ; introduire ensuite chaque domaine dans son propre modèle/provider/repository/service. Les transactions/registre de récompenses et les règles minimales doivent être conçus avant la première attribution d'Éclats, même si la roadmap documentaire reporte la sécurisation générale après le Sprint 15.

## 2. État réel du dépôt

### 2.1 Chiffres

| Élément | État réel |
|---|---:|
| Fichiers Dart sous `lib/` | 142 |
| Lignes Dart approximatives | 22 513 |
| `core/` | 27 fichiers |
| `models/` | 19 fichiers |
| `pages/` | 26 fichiers |
| `providers/` | 16 fichiers |
| `repositories/` | 3 fichiers |
| `routes/` | 1 fichier |
| `services/` | 10 fichiers |
| `widgets/` | 38 fichiers |
| Tests Flutter | 0 ; dossier `test/` absent |
| Assets | 105 fichiers, environ 149,97 Mo au total |
| Images déclarées dans le bundle | environ 124,13 Mo |
| Règles Firestore/Storage versionnées | aucune |

### 2.2 Arborescence utile

```text
android/                 configuration et runner Android
assets/
  data/                  académies et vacances scolaires
  images/                avatars, fonds, mascotte, objets, récompenses, routines
  source/                sources graphiques non déclarées dans pubspec
docs/                    contexte, règles, statut, roadmap, conception parent
ios/                     configuration et runner iOS
lib/
  core/                  thème, constantes, assets, undo
  models/                modèles famille, enfant, planning, agenda, parent
  pages/                 écrans parent, onboarding et journée enfant
  providers/             état Riverpod et actions
  repositories/          logique famille/planning et espace parent
  routes/                GoRouter unique
  services/              Auth, Firestore, données locales JSON
  widgets/               composants communs, parent et enfant
Sprint15/                spécifications fonctionnelles validées
web/, windows/, linux/,
macos/                   runners Flutter générés
```

### 2.3 État Git au début de l'audit

Le worktree était déjà très chargé : nombreux fichiers modifiés, supprimés et non suivis dans Android, iOS, assets, documentation et `lib/`. L'ancien `AGENTS.md` racine apparaît supprimé tandis que `docs/AGENTS.md` est non suivi. Cet audit n'attribue pas ces changements et ne les modifie pas. Cette situation réduit la traçabilité et augmente le risque de mélanger Sprint 15 avec des travaux en cours ; un point de référence Git propre est recommandé avant toute implémentation.

### 2.4 Vérifications exécutées

| Commande | Résultat |
|---|---|
| `flutter analyze` | succès, « No issues found » |
| `dart format --output=none --set-exit-if-changed lib` | échec attendu de contrôle : 6 fichiers seraient reformattés |
| Contrôle `test` | dossier absent, donc non inclus dans la commande de format |
| `flutter test` | échec : `Test directory "test" not found.` |
| Recherche imports inutilisés | aucun import inutilisé signalé par l'analyseur |
| Recherche anciens concepts enfant | mascotte, récompenses, « Privilèges » et accueil historique encore présents |

Fichiers signalés par le contrôle de format : `lib/models/routine_model.dart`, `lib/models/step_model.dart`, `lib/pages/child_avatar_picker_page.dart`, `lib/pages/today_page.dart`, `lib/widgets/primary_button.dart`, `lib/widgets/secondary_button.dart`. L'option `--output=none` n'a écrit aucun changement.

## 3. Cartographie de l'architecture

### 3.1 Flux réellement dominant

```text
Page/Widget
   ↓ ref.watch / ref.read
Provider Riverpod
   ↓
FamilyRepository (très large) ou ParentSpaceRepository
   ↓
FirestoreService (très large), ParentSpaceService, AuthService, services JSON
   ↓
Firebase Auth / Firestore / assets JSON
```

Le flux officiel est globalement respecté pour les fonctionnalités métier récentes. Il existe néanmoins des contournements :

- `lib/pages/splash_page.dart` construit directement `FamilyRepository`.
- `lib/pages/create_family_page.dart`, `lib/pages/login_page.dart`, `lib/pages/dashboard_page.dart` et `lib/pages/select_avatar_page.dart` appellent directement `familyRepositoryProvider`, sans notifier d'action dédié.
- `lib/pages/create_family_page.dart` et `lib/pages/login_page.dart` importent `firebase_auth` pour interpréter les exceptions. Ce n'est pas un accès direct à Firebase, mais cela couple la présentation à une technologie de service.
- `lib/widgets/dashboard/children_card.dart` et `lib/widgets/dashboard/greeting_card.dart` consomment directement des providers. C'est acceptable pour des widgets de composition, mais ils ne sont pas purement présentiels.

Aucun accès direct à `FirebaseFirestore` n'a été trouvé dans une Page, un Widget ou un Provider. Les imports Firestore sont contenus dans les services.

### 3.2 Écarts architecturaux

| Écart | Fichiers | Dette | Risque |
|---|---|---|---|
| Repository directement instancié par une Page | `lib/pages/splash_page.dart` | contourne injection et testabilité | élevé |
| Appels Repository depuis Pages | create/login/dashboard/select avatar | orchestration et erreurs dans l'UI | moyen |
| Repository famille omniscient | `lib/repositories/family_repository.dart` | 1 947 lignes, 17 modèles importés | élevé |
| Service Firestore omniscient | `lib/services/firestore_service.dart` | 925 lignes, schémas hétérogènes | élevé |
| Services modulaires abandonnés | `lib/services/firestore/*.dart` | doublons non branchés | moyen |
| Deux applications/thèmes | `lib/main.dart`, `lib/core/app.dart`, deux thèmes | source de vérité ambiguë | moyen |
| Logique UI massive | pages/widgets > 500 lignes | régression et tests difficiles | élevé |

## 4. Inventaire fichier par fichier

Les colonnes « décision » regroupent conservation, modification et réutilisation Sprint 15. Les risques qualifient l'impact d'une erreur ou d'une modification dans le fichier.

### 4.1 Démarrage, routeur et configuration

| Chemin exact | Rôle et dépendances | Décision / réutilisation Sprint 15 | Dette | Risque |
|---|---|---|---|---|
| `lib/main.dart` | initialise Firebase, UI système, Riverpod et `MaterialApp.router`; dépend de `firebase_options.dart`, GoRouter et `BoussoleTheme` | conserver et modifier en 15.1 pour bootstrap du mode d'appareil | duplique `core/app.dart` | élevé |
| `lib/firebase_options.dart` | options FlutterFire Android/Web | conserver ; régénérer séparément quand iOS sera activé, sans le faire pendant cet audit | iOS/macOS/Windows/Linux lèvent `UnsupportedError` | élevé |
| `lib/routes/app_router.dart` | 24 routes plates, objets passés via `state.extra` | modifier fortement en 15.1 ; ajouter séparation parent/enfant, paramètres d'URL et gardes | aucun redirect, routes non restaurables | critique |
| `lib/core/app.dart` | seconde classe `BoussoleApp`, thème alternatif | ne pas réutiliser ; supprimer après décision, hors premier changement fonctionnel | mort/doublon | faible |
| `lib/core/app_providers.dart` | provider booléen toujours vrai | ne pas réutiliser | mort | faible |
| `lib/core/app_exports.dart` | barrel des anciens fichiers core | ne pas étendre avant nettoyage | non référencé | faible |
| `pubspec.yaml` | dépendances et assets | conserver ; aucune mise à jour pendant l'audit ; valider séparément les dépendances de sécurité PIN/backend | dépendances inutilisées et bundle lourd | moyen |
| `firebase.json` | configuration FlutterFire uniquement | modifier lorsque les règles/index seront ajoutés | aucune référence rules/indexes | critique |
| `analysis_options.yaml` | lints Flutter par défaut | conserver ; renforcer plus tard | règles minimales | faible |

### 4.2 Pages

| Chemin exact | Rôle actuel / dépendances principales | Décision Sprint 15 | Dette | Risque |
|---|---|---|---|---|
| `lib/pages/splash_page.dart` | restaure la session puis ouvre `/home`; Repository direct | modifier 15.1 : résoudre auth + mode + profil + verrou via provider | violation de couche, délai fixe 2 s | élevé |
| `lib/pages/welcome_page.dart` | compose l'accueil non connecté | conserver | mascotte historique | faible |
| `lib/pages/login_page.dart` | connexion Firebase via repository | conserver, déplacer orchestration/erreurs vers provider | Page couplée aux exceptions Firebase ; boutons Google/reset inertes | moyen |
| `lib/pages/create_family_page.dart` | crée compte, famille et session | conserver, sécuriser l'écriture atomique côté domaine | création partielle possible ; CGU non liées | élevé |
| `lib/pages/family_members_page.dart` | onboarding initial des membres | conserver | le parent authentifié n'est pas créé comme membre avec son UID | élevé |
| `lib/pages/create_adult_page.dart` | ajout d'un adulte | conserver | profil adulte sans identité Auth propre | moyen |
| `lib/pages/create_child_page.dart` | début du brouillon enfant | conserver | flux éclaté sur plusieurs pages/providers | moyen |
| `lib/pages/select_child_avatar_page.dart` | finalise profil, académie et rythme | conserver | 425 lignes, responsabilités multiples | moyen |
| `lib/pages/select_avatar_page.dart` | avatar du parent/session | conserver si route encore utile ; passer par notifier | appel repository dans Page | moyen |
| `lib/pages/dashboard_page.dart` | véritable accueil parent, accès enfants, agenda et réglages | conserver comme accueil parent ; modifier les cartes enfant pour ouvrir Maison/sélecteur | 727 lignes ; sign-out direct repository | élevé |
| `lib/pages/accueil_page.dart` | ancien accueil illustré avec mascotte et texte Gardien | remplacer par `HousePage`, ne pas réactiver | fichier mort, ancien concept | faible |
| `lib/pages/today_page.dart` | « Ma journée », sélection enfant, progression, privilèges, fin de journée | **conserver** ; imbriquer sous espace enfant et modifier retours/visuels | 1 242 lignes, mascotte gagnante, `/home`, logique riche | élevé |
| `lib/pages/child_routine_page.dart` | déroule les étapes d'une routine et complète le moment | conserver et réutiliser depuis Ma journée | route dépend d'objets `extra` | moyen |
| `lib/pages/child_avatar_picker_page.dart` | change l'avatar d'un membre enfant depuis gestion parent | conserver côté parent uniquement | nom pouvant faire croire à un écran enfant | faible |
| `lib/pages/day_planner_page.dart` | configure les journées et moments d'un enfant | conserver côté parent ; source majeure du Moteur | 563 lignes | élevé |
| `lib/pages/select_moment_page.dart` | catalogue de presets de moments | conserver | faible séparation UI | faible |
| `lib/pages/create_moment_settings_page.dart` | crée et paramètre un moment | conserver | 727 lignes, duplication avec édition | élevé |
| `lib/pages/edit_moment_page.dart` | modifie un moment | conserver | 670 lignes, champs dupliqués | élevé |
| `lib/pages/moment_routines_page.dart` | CRUD/ordre des routines d'un moment | conserver côté parent | dialogues et actions dans Page | moyen |
| `lib/pages/routine_steps_page.dart` | CRUD/ordre des étapes | conserver côté parent | dialogues et actions dans Page | moyen |
| `lib/pages/family_agenda_page.dart` | agenda familial, recherche et filtres | conserver | 764 lignes, duplication d'agenda parent | élevé |
| `lib/pages/family_event_form_page.dart` | création/édition d'événements | conserver ; le moteur pourra lire ses événements | 673 lignes ; `endTime` historique incohérent | élevé |
| `lib/pages/family_members_management_page.dart` | gestion courante des membres | conserver côté parent | recoupe onboarding `family_members_page.dart` | moyen |
| `lib/pages/member_detail_page.dart` | édition profil, académie, rythme, suppression | conserver ; futur point d'édition du profil d'expérience enfant | 500 lignes | élevé |
| `lib/pages/family_settings_page.dart` | nom, e-mail, mot de passe | conserver et étendre en 15.1 pour paramètres appareil/PIN | action multi-système non atomique | élevé |
| `lib/pages/parent_space_page.dart` | agenda personnel et matrice de tâches | conserver sans l'impacter en Sprint 15 | 677 lignes | élevé |

### 4.3 Providers Riverpod

| Chemin exact | Rôle / dépendances | Décision Sprint 15 | Dette | Risque |
|---|---|---|---|---|
| `lib/providers/session_provider.dart` | session en mémoire | conserver ; séparer session Auth et contexte d'espace/device | aucun état de verrou ou mode | élevé |
| `lib/providers/family_provider.dart` | injecte `FamilyRepository`, famille et adultes | conserver ; ne pas y ajouter Sprint 15 | repository global trop large | élevé |
| `lib/providers/family_action_notifier.dart` | base `AsyncValue` pour actions familiales | réutiliser ou généraliser pour nouveaux notifiers | erreurs consommées manuellement | moyen |
| `lib/providers/children_provider.dart` | enfants, profils utilisables, rythme hebdomadaire | conserver ; source de sélection enfant | dépend session/repository global | élevé |
| `lib/providers/child_creation_provider.dart` | brouillon et enregistrement enfant | conserver | deux notifiers dans un fichier | moyen |
| `lib/providers/adult_creation_provider.dart` | ajout adulte | conserver | identité adulte distincte de Firebase Auth | moyen |
| `lib/providers/family_members_provider.dart` | agrège adultes/enfants et actions membre | conserver côté parent | invalidations manuelles | moyen |
| `lib/providers/family_settings_provider.dart` | mise à jour famille/Auth | conserver ; ne pas y mélanger le PIN | action partiellement appliquée possible | élevé |
| `lib/providers/academy_provider.dart` | académies depuis JSON | conserver ; entrée profil du moteur | cache limité à la vie du provider | faible |
| `lib/providers/moments_provider.dart` | cible planning, moments/journée, CRUD et exceptions | **conserver** ; source principale de Ma journée/Moteur | 365 lignes, nombreux notifiers | élevé |
| `lib/providers/routines_provider.dart` | routines par moment et actions | conserver/réutiliser | invalidation par objet modèle | moyen |
| `lib/providers/steps_provider.dart` | étapes et actions | conserver/réutiliser | invalidation par objet modèle | moyen |
| `lib/providers/child_day_progress_provider.dart` | état de la journée, compteurs, ordre, reset et persistance | **conserver mais modifier avant Éclats** ; source UI, jamais ledger de récompense | 496 lignes ; document complet last-write-wins ; pas de flux temps réel | critique pour 15.3 |
| `lib/providers/family_events_provider.dart` | événements et actions agenda | conserver ; contexte du moteur/missions | chargement complet puis filtrage client | moyen |
| `lib/providers/parent_space_provider.dart` | événements/tâches parent et actions | conserver hors Sprint 15 | 254 lignes | moyen |
| `lib/providers/dashboard_refresh_provider.dart` | invalide plusieurs providers | conserver temporairement | liste manuelle fragile | moyen |

### 4.4 Repositories et resolver

| Chemin exact | Rôle / dépendances | Décision Sprint 15 | Dette | Risque |
|---|---|---|---|---|
| `lib/repositories/family_repository.dart` | Auth, famille, membres, agenda, planning, moments, routines, étapes, progression | conserver pour l'existant ; **ne pas ajouter** Maison/Gardiens/Éclats/Missions | 1 947 lignes, trop de domaines, opérations séquentielles | critique |
| `lib/repositories/parent_space_repository.dart` | métier agenda/tâches parent | conserver sans extension Sprint 15 | synchronisation événement partagé parfois non atomique | élevé |
| `lib/repositories/planning_day_resolver.dart` | résout école/mercredi/week-end/vacances | conserver et réutiliser dans le Moteur des Repères | dépend services concrets, peu testable sans injection provider | moyen |

### 4.5 Services

| Chemin exact | Rôle / dépendances | Décision Sprint 15 | Dette | Risque |
|---|---|---|---|---|
| `lib/services/auth_service.dart` | Firebase Auth e-mail/mot de passe | conserver | pas de reset password/réauth explicite | élevé |
| `lib/services/firestore_service.dart` | service Firestore actif pour presque tout | conserver puis découper progressivement ; ne pas y empiler Sprint 15 | 925 lignes, schémas manuels/ISO mixtes | critique |
| `lib/services/parent_space_service.dart` | collections parent et batches de planification | conserver | seulement certaines opérations sont atomiques | élevé |
| `lib/services/academy_service.dart` | charge académies JSON | conserver/réutiliser | erreurs de données remontent tard | faible |
| `lib/services/school_holiday_service.dart` | charge vacances JSON par année/zone | conserver/réutiliser dans moteur | données 2027–2029 vides | élevé pour personnalisation calendrier |
| `lib/services/firestore/child_firestore_service.dart` | extraction partielle du service enfant | soit brancher lors d'un refactor dédié, soit supprimer | inutilisé, doublon | moyen |
| `lib/services/firestore/moment_firestore_service.dart` | extraction partielle moments | idem | inutilisé, API moins complète | moyen |
| `lib/services/firestore/parent_firestore_service.dart` | extraction partielle parent/index | idem | inutilisé et schéma déjà divergent (`age`, `profileType`) | élevé |
| `lib/services/firestore/routine_firestore_service.dart` | extraction partielle routines | idem | inutilisé | moyen |
| `lib/services/firestore/step_firestore_service.dart` | extraction partielle étapes | idem | inutilisé | moyen |

### 4.6 Models

| Chemin exact | Rôle actuel | Décision / extension Sprint 15 | Dette | Risque |
|---|---|---|---|---|
| `lib/models/session_model.dart` | contexte utilisateur/famille/rôle | conserver ; ne pas confondre avec mode d'appareil ou déverrouillage | rôle enfant jamais alimenté par Auth | élevé |
| `lib/models/user_role.dart` | enum parent/enfant | conserver, clarifier auth vs profil | une ligne, sémantique incomplète | moyen |
| `lib/models/family_model.dart` | identité famille | conserver | `toMap/fromMap` ISO non utilisés par service actif qui stocke `info` + Timestamp | élevé |
| `lib/models/parent_model.dart` | profil adulte | conserver | `uid` peut être ID aléatoire et non UID Auth ; sérialisation divergente | élevé |
| `lib/models/child_model.dart` | identité, âge, avatar, académie, rythme | conserver ; éviter d'y accumuler toute l'expérience, préférer `ChildExperienceProfile` | casts stricts et Date ISO vs Timestamp | élevé |
| `lib/models/child_creation_model.dart` | brouillon onboarding | conserver | pas de sérialisation | faible |
| `lib/models/family_member_model.dart` | vue unifiée parent/enfant | conserver côté UI | modèle projection, pas source de vérité | moyen |
| `lib/models/day_type_model.dart` | planning par type/rythme | conserver ; entrée du moteur | nom historique `DayType` | moyen |
| `lib/models/day_exception_model.dart` | exception datée d'un planning enfant | conserver ; entrée du moteur | champ `dayTypeId` aliasé `familyPlanningId` | moyen |
| `lib/models/planning_day_kind.dart` | école/mercredi/week-end/vacances | conserver/réutiliser | texte enfant contient `ecole` sans accent | faible |
| `lib/models/moment_model.dart` | moment planifié et options temps/multiusage | conserver/étendre seulement si nécessaire | chaînes libres pour modes ; casts stricts | élevé |
| `lib/models/routine_model.dart` | routine liée à un moment | conserver | format non conforme ; champs sans `familyId` | moyen |
| `lib/models/step_model.dart` | étape de routine | conserver | format non conforme ; description obligatoire stricte | moyen |
| `lib/models/child_day_item_model.dart` | projection moment/événement pour Ma journée | conserver ; excellente frontière UI/moteur | non sérialisé | faible |
| `lib/models/child_day_progress_model.dart` | statuts quotidiens, compteurs, ordre | conserver pour l'UI ; **ne pas ajouter le solde d'Éclats** | sauvegarde complète et horodatage client | critique pour anti-triche |
| `lib/models/family_event_model.dart` | événement familial et repère enfant | conserver ; entrée Moteur/Missions si référencé | `endTime` lu/copié mais omis de `toMap`; anciens modes convertis | élevé |
| `lib/models/parent_personal_event_model.dart` | événement personnel parent | conserver | chaînes libres | moyen |
| `lib/models/parent_task_model.dart` | matrice, étapes, rappels, cycle de vie | conserver hors Sprint 15 | 362 lignes, modèle riche | moyen |
| `lib/models/school_academy.dart` | académie/zone | conserver | valeur par défaut technique exposée | faible |

### 4.7 Widgets réutilisables et dette UI

| Chemin(s) exact(s) | Rôle / réutilisation | Décision | Dette | Risque |
|---|---|---|---|---|
| `lib/widgets/child/child_moment_card.dart` | carte enfant avec états, minuterie et repères doux | réutiliser dans Ma journée ; scinder avant grosse évolution | 748 lignes | élevé |
| `lib/widgets/boussole_button.dart` | bouton animé principal/secondaire | réutiliser partout Sprint 15 | API `isPrimary` plutôt qu'un style typé | faible |
| `lib/widgets/common/app_card.dart`, `section_card.dart`, `loading_card.dart`, `empty_state.dart`, `info_tile.dart` | primitives de carte/état | réutiliser pour écrans parent et chargements ; adapter visuellement la Maison | coexistence avec `BoussoleCard` | faible |
| `lib/widgets/common/boussole_app_bar.dart` | app bar avec retour GoRouter | conserver parent ; ne pas imposer à la Maison immersive | navigation implicite | moyen |
| `lib/widgets/common/avatar_circle.dart`, `lib/widgets/avatar/avatar_grid.dart` | affichage/sélection avatar | réutiliser pour sélecteur d'enfant partagé | dépend registre d'avatars | faible |
| `lib/widgets/common/moment_card.dart`, `moment_preset_card.dart` | cartes planning parent | conserver | proches mais rôles distincts | faible |
| `lib/widgets/agenda/compact_expandable_event_card.dart` | carte événement extensible | réutiliser hors Maison | état local | faible |
| `lib/widgets/family/family_event_card.dart`, `family_event_style.dart`, `family_member_form_card.dart` | agenda et membres | conserver | aucune dette Sprint 15 directe | faible |
| `lib/widgets/parent_space/parent_agenda_section.dart` | agenda personnel filtré | conserver | 585 lignes et duplication avec page agenda | élevé |
| `lib/widgets/parent_space/parent_event_form_sheet.dart` | formulaire événement personnel | conserver | 458 lignes | moyen |
| `lib/widgets/parent_space/parent_task_card.dart` | carte tâche | conserver | 391 lignes | moyen |
| `lib/widgets/parent_space/parent_task_form_sheet.dart` | formulaire tâche | conserver | 590 lignes | élevé |
| `lib/widgets/parent_space/parent_tasks_matrix.dart` | matrice Eisenhower | conserver | 474 lignes | élevé |
| `lib/widgets/dashboard/children_card.dart`, `greeting_card.dart`, `parent_avatar.dart` | anciens composants dashboard | `parent_avatar` réutilisable ; deux premiers semblent supplantés par widgets privés de `DashboardPage` | composants possiblement morts | faible |
| `lib/widgets/welcome/*` | écran bienvenue et mascotte | conserver en 15.1 ; remplacer la mascotte selon décision de marque en 15.2 | ancien concept mascotte | moyen |
| `lib/widgets/boussole_card.dart` | primitive carte alternative | consolider avec `AppCard` ou supprimer | non référencé | faible |
| `lib/widgets/boussole_scaffold.dart`, `boussole_text_field.dart`, `boussole_spacing.dart` | primitives historiques | évaluer avant réemploi ; actuellement non référencées | mortes ou quasi mortes | faible |
| `lib/widgets/primary_button.dart`, `secondary_button.dart` | fichiers vides | supprimer après nettoyage | morts et non formatés | faible |

### 4.8 Core restant

`lib/core/app_assets.dart`, `app_colors.dart`, `app_text_styles.dart` sont largement utilisés et doivent être conservés puis étendus prudemment. `lib/core/constants/avatar_constants.dart` et `moment_presets.dart` sont des registres actifs à conserver. `lib/core/theme/boussole_theme.dart` est le thème actif ; `lib/core/app_theme.dart` et `lib/core/theme/boussole_colors.dart` forment un second système seulement partiellement utilisé via le fichier mort `core/app.dart`.

Les petits fichiers `app_animation.dart`, `app_border_radius.dart`, `app_config.dart`, `app_constants.dart`, `app_durations.dart`, `app_icons.dart`, `app_radius.dart`, `app_shadows.dart`, `app_sizes.dart`, `app_spacing.dart`, `app_strings.dart`, `app_theme_extension.dart`, `app_typedefs.dart` constituent une ancienne bibliothèque de tokens très peu ou pas référencée. Ne pas créer un troisième système : choisir entre ces tokens et le système actif avant le travail visuel lourd de la Maison. `app_constants.dart` contient déjà `parentPinLength = '4'` sous forme de chaîne, sans usage : ne pas le considérer comme une décision produit suffisante.

`lib/core/undo/undo_action.dart`, `undo_manager.dart`, `undo_provider.dart` forment une fonctionnalité undo non branchée. Elle peut être utile pour la décoration de Maison, mais doit être testée et reliée par un provider métier plutôt que réutilisée aveuglément.

## 5. Analyse des dépendances

### Dépendances réellement utilisées

- `go_router` : routeur central, à conserver.
- `flutter_riverpod` : état et injection, à conserver.
- `firebase_core`, `firebase_auth`, `cloud_firestore` : socle distant actif.
- `flutter_animate` : animation du splash uniquement.
- `google_fonts` : thème et welcome.
- `flutter_localizations` : locale française.

### Dépendances déclarées sans import applicatif

- `hive`, `hive_flutter`, `path_provider` : aucun import dans `lib/`. Elles peuvent être réutilisées en 15.1 pour la configuration **locale par appareil**, après définition explicite du schéma et de sa durée de vie.
- `firebase_storage` : aucun import ; aucun usage ni règles Storage.
- `build_runner`, `hive_generator` : aucun adapter/annotation Hive présent.
- `cupertino_icons` : aucun import direct relevé.

Il ne faut pas supprimer ou mettre à jour ces dépendances pendant Sprint 15.1 sans décision propriétaire. Pour un PIN robuste, les dépendances actuelles ne fournissent ni stockage sécurisé natif ni KDF dédiée. Il faut décider entre backend callable, stockage sécurisé local, réauthentification Firebase ou ajout validé de dépendances telles que stockage sécurisé/crypto. Un simple hash rapide ou un PIN en clair dans Hive/Firestore est interdit.

## 6. Analyse GoRouter

### État actuel

- Route initiale `/` vers `SplashPage`.
- Toutes les routes sont au même niveau.
- Aucun `redirect`, `refreshListenable`, `ShellRoute` ou garde d'authentification.
- Les erreurs d'arguments renvoient souvent une Page de repli, sans URL canonique.
- De nombreuses routes utilisent `state.extra` avec des modèles complets (`FamilyMemberModel`, `MomentModel`, `RoutineModel`, événements). Elles ne sont ni restaurables après fermeture, ni partageables, ni robustes aux deep links.
- `/today` accepte un `childId` dans `extra`; en son absence, le premier enfant est choisi.
- La fin de journée renvoie explicitement à `/home`, donc à l'espace parent.

### Routes nécessaires

Architecture recommandée, avec anciens chemins conservés temporairement comme redirections :

```text
/                         bootstrap seulement
/welcome
/login
/onboarding/...

/parent/home
/parent/members
/parent/planner
/parent/agenda
/parent/settings
/parent/settings/device
/parent/unlock

/child/select
/child/:childId/house
/child/:childId/today
/child/:childId/routine/:routineId
/child/:childId/findings
/child/:childId/shared-moments
/child/:childId/guardian
/child/:childId/missions/:missionId
```

Le redirect global doit évaluer dans cet ordre : état Firebase Auth, onboarding famille, mode de l'appareil, enfant autorisé/sélectionné, état verrouillé/déverrouillé de l'espace parent. Les paramètres de chemin doivent être validés contre la famille courante par repository, jamais seulement parce qu'un ID est fourni dans l'URL.

## 7. Analyse Firebase et Firestore

### 7.1 Authentification

`AuthService` prend en charge création, connexion, déconnexion, changement d'e-mail et mot de passe. La restauration repose sur `FirebaseAuth.currentUser`, puis `users/{uid}.familyId`. La session Riverpod est seulement en mémoire.

Risques :

- création de famille en trois écritures séquentielles : compte Auth, document famille, index utilisateur ; une panne laisse un état partiel ;
- aucun document parent authentifié n'est créé avec l'UID lors de `createFamily`; les adultes ajoutés reçoivent des IDs aléatoires, créant une ambiguïté entre identité Auth et profil adulte ;
- `updateFamilySettings` modifie d'abord Firestore, puis e-mail et mot de passe Auth ; une réauthentification requise ou un échec laisse des données partiellement mises à jour ;
- pas de reset password effectif, malgré un bouton visible ;
- pas d'App Check visible ;
- options FlutterFire uniquement Android/Web, alors que le runner iOS existe.

### 7.2 Collections observées

```text
users/{uid}
families/{familyId}
families/{familyId}/members/{parentId}
families/{familyId}/children/{childId}
families/{familyId}/children/{childId}/day_progress/{yyyy-MM-dd}
families/{familyId}/events/{eventId}
families/{familyId}/day_types/{dayTypeId}
families/{familyId}/day_exceptions/{date_childId}
families/{familyId}/moments/{momentId}
families/{familyId}/routines/{routineId}
families/{familyId}/routines/{routineId}/steps/{stepId}
families/{familyId}/parentSpaces/{parentId}/events/{eventId}
families/{familyId}/parentSpaces/{parentId}/tasks/{taskId}
```

### 7.3 Règles et index

Aucun `firestore.rules`, `storage.rules` ou `firestore.indexes.json` n'existe. `firebase.json` ne déclare que FlutterFire. Il est donc impossible de vérifier : appartenance à une famille, droits parent/enfant, transitions de mission, protection d'un solde, ou limitation d'accès à un autre `familyId`.

Les requêtes `where('momentId').orderBy('order')` nécessitent une stratégie d'index reproductible. Même si l'index distant existe, son absence du dépôt est une dette de déploiement.

### 7.4 Sérialisation

- Famille, parent et enfant sont écrits manuellement avec des `Timestamp`, alors que leurs `toMap/fromMap` utilisent des chaînes ISO. Une réutilisation naïve de ces méthodes casserait le schéma.
- Moments, routines, étapes, événements et progression utilisent des chaînes ISO.
- `FamilyEventModel.endTime` est lu et copié mais n'est pas écrit dans `toMap`. Les nouveaux flux mettent systématiquement `endTime` à `null`; le champ est une compatibilité incomplète.
- Plusieurs `fromMap` font des casts stricts (`as int`, `DateTime.parse`) sans tolérance aux `num`, `Timestamp` ou champs manquants. Une donnée ancienne ou manuelle peut faire échouer un écran entier.
- Les services Firestore modulaires inutilisés dupliquent les schémas et ont déjà divergé, notamment `ParentFirestoreService` qui omet des champs présents dans le service actif.

### 7.5 Atomicité

Les batches sont correctement utilisés pour réordonner moments/routines/étapes et pour planifier/déplanifier une tâche avec ses événements liés. En revanche :

- création de famille/index/Auth non atomique ;
- initialisation d'un enfant : document enfant, 20 moments initiaux et 4 plannings écrits séquentiellement ;
- création d'un moment puis ajout au planning non atomique ;
- duplication d'un moment/routines/étapes/réordonnancement/planning non atomique ;
- duplication d'un rythme écrit chaque moment puis le planning ;
- suppression d'un membre ne nettoie pas les sous-données/références ;
- suppression d'une routine ne nettoie pas explicitement sa sous-collection `steps` ;
- création/mise à jour/suppression d'un événement personnel partagé écrit l'événement familial puis personnel séquentiellement ;
- progression quotidienne remplacée en totalité, sans transaction ni contrôle de version.

## 8. Analyse des Assets et du thème

### Assets

- Aucun asset nommé Crystal, Pixel, Pyro, Gear, Wave, Gardien, Maison, Éclat, Trouvaille ou Mission n'existe.
- Les images déclarées représentent environ 124,13 Mo, plusieurs PNG individuels dépassant 3 Mo. Cela pénalise taille d'installation, mémoire et temps de décodage.
- Chemins référencés mais absents : `assets/images/objects/cap.png`, `pants.png`, `shirt.png`, `shoes.png`. Les fichiers existent désormais sous `assets/images/routines/`, mais `AppAssets` pointe encore vers `objects/`.
- `assets/images/badges/` est déclaré mais vide.
- `assets/source/` pèse environ 25,82 Mo et n'est pas déclaré dans `pubspec`, ce qui est correct pour des sources de travail.
- Les fichiers vacances 2027, 2028 et 2029 sont identiques et ne contiennent que des listes vides. Le moteur ne pourra pas détecter les vacances au-delà de 2026.
- `AppAssets.icon` pointe vers `logo.png`, alors que l'icône launcher est `app_icon.png`.

### Thème

Le thème actif est `lib/core/theme/boussole_theme.dart`, tandis que presque toute l'UI consomme directement `AppColors` et `AppTextStyles`. `AppTheme`/`BoussoleColors` constituent un doublon. La couleur d'erreur diverge même entre les palettes (`0xFFE57373` et `0xFFE53773`).

Avant les visuels de Maison, établir une seule source de vérité : tokens communs, thème parent, extension/thème enfant. Il est préférable d'ajouter une `ThemeExtension` enfant ou des tokens Maison/Gardien plutôt que multiplier les couleurs codées en dur. La Maison doit rester immersive et ne pas réutiliser automatiquement l'AppBar parent noire/bleue.

## 9. Composants réutilisables

### À réutiliser directement

- `TodayPage`, `ChildRoutinePage`, `ChildMomentCard` pour « Ma journée ».
- `childDayItemsProvider`, `childDayProgressProvider`, `routinesForMomentProvider`, `stepsForRoutineProvider`.
- `PlanningDayResolver`, `PlanningDayKind`, `MomentModel`, `RoutineModel`, `StepModel`, `ChildDayItemModel` comme entrées du Moteur des Repères.
- `childrenProvider`, `familyMembersProvider`, `AvatarGrid`, `AvatarCircle` pour les modes téléphone familial/tablette partagée.
- `SchoolHolidayService` et `AcademyService`, après correction des données calendrier.
- `BoussoleButton`, `EmptyState`, `LoadingCard`, `AppCard` pour les flux secondaires.
- `AppAssets` et les fonds existants uniquement comme placeholders 15.1, pas comme Maison finale.

### À conserver mais encapsuler

- `FamilyRepository` et `FirestoreService` pour les domaines existants ; les nouveaux domaines doivent avoir leurs propres repositories/services.
- `SessionProvider` doit rester la session Auth, avec des providers séparés pour mode d'appareil, enfant actif et verrou parent.
- `ChildDayProgressModel` reste la progression visuelle de la journée, séparée du registre d'Éclats.

### À ne pas réutiliser comme fondation Sprint 15

- `AccueilPage`, `core/app.dart`, `app_providers.dart`.
- les services `lib/services/firestore/*` tant qu'ils ne sont pas officiellement branchés et complétés ; leur simple présence ne constitue pas une architecture modulaire active.
- `primary_button.dart` et `secondary_button.dart`, vides.
- la mascotte historique comme substitut temporaire permanent des Gardiens.

## 10. Dette technique

1. **Monolithes** : `FamilyRepository`, `FirestoreService`, `TodayPage`, pages agenda/formulaires et widgets parent très volumineux.
2. **Code mort/doublons** : deux apps, deux thèmes, accueil mort, widgets vides, primitives non utilisées, services Firestore non branchés.
3. **Navigation fragile** : objets en `extra`, routes plates, fallback silencieux, aucune garde.
4. **Schémas hétérogènes** : Timestamp/ISO, casts stricts, alias historiques.
5. **Invalidation manuelle** : plusieurs providers doivent être invalidés explicitement après chaque action.
6. **Pas de temps réel pour Ma journée** : Future providers et sauvegarde globale ; mauvais ajustement aux trois modes multi-appareils.
7. **Absence de tests** : aucune protection de sérialisation, planning, concurrence, navigation ou sécurité.
8. **Assets non optimisés** : poids élevé, chemins manquants, aucun catalogue Sprint 15.
9. **Données calendrier incomplètes** : vacances après 2026 vides.
10. **Worktree non stabilisé** : audit et futurs changements difficiles à isoler.

## 11. Risques de régression

| Risque | Niveau | Prévention |
|---|---|---|
| Un enfant accède aux écrans parent via URL/retour | critique | gardes GoRouter + verrou central + tests navigation |
| Solde d'Éclats attribué plusieurs fois ou modifié par client | critique | ledger déterministe + transaction/backend + rules |
| Reset de journée redonne une récompense | critique | ledger séparé non supprimé par reset |
| Deux appareils écrasent la progression | élevé | transaction/version ou opérations atomiques par champ + stream |
| Données partielles lors de création enfant/planning | élevé | batch/transaction/idempotence |
| Orphelins après suppression membre/routine | élevé | stratégie cascade explicite et testée |
| Rupture des routes au passage aux path params | élevé | redirections temporaires et tests GoRouter |
| Régression de « Ma journée » | élevé | tests provider + widget + parcours avant intégration Maison |
| Crash sur ancienne donnée Firestore | élevé | parseurs tolérants et tests de compatibilité |
| Taille/mémoire aggravée par assets Maison | élevé | budgets d'assets, WebP/PNG optimisés, résolution adaptée |
| Régression espace parent lors du bootstrap device mode | élevé | séparation stricte des shells et tests par mode |
| Moteur propose autre chose que deux choix | moyen | type `GuidancePair` impossible à construire avec 1/3 choix |

## 12. Écrans conservés et remplacés

### Conservés

- `TodayPage` devient l'écran **Ma journée** sous `/child/:childId/today`. Sa logique de moments, événements, ordre, multiusage et routines est précieuse.
- `ChildRoutinePage` reste le détail d'une routine enfant.
- Tout l'espace parent : `DashboardPage`, planning, agenda, membres, réglages, espace personnel.
- Onboarding/authentification, sous réserve des gardes et corrections d'identité.

### Remplacés ou recontextualisés

- L'ouverture directe `DashboardPage → /today` est remplacée par `DashboardPage → HousePage` ou `ChildSelectorPage → HousePage` selon le mode.
- `AccueilPage` est remplacée par une nouvelle `HousePage`; elle ne doit pas être remise en route.
- La fin de `TodayPage` ne doit plus utiliser `mascotWinner` ni retourner à `/home`; elle célèbre via le Gardien puis retourne à la Maison. Le remplacement du personnage final peut être livré en 15.2, mais la fuite vers l'espace parent doit être corrigée en 15.1.
- La section « Privilèges » de `TodayPage` représente aujourd'hui les moments multiusage. Elle doit être renommée/repositionnée selon le vocabulaire Sprint 15 ; elle n'est pas la future économie des Éclats.
- `WelcomeMascot` et les assets `mascotte/` doivent faire l'objet d'une décision de marque : accueil générique conservé ou Gardien présenté dès l'onboarding. Ils ne doivent pas coexister sans explication avec les Gardiens.

## 13. Nouveaux éléments nécessaires

### 13.1 Domaines et responsabilités

| Domaine | Modèles | Provider | Repository | Service/source |
|---|---|---|---|---|
| Modes d'appareil | `DeviceMode`, `DeviceConfiguration` | bootstrap/mode/enfant actif | `DeviceAccessRepository` | stockage local + éventuelle config famille |
| Accès parent | `ParentLockState`, politique de tentative | `parentAccessProvider` | `ParentAccessRepository` | service PIN sécurisé/backend |
| Profil expérience enfant | `ChildExperienceProfile` | profil/interests/autonomie | `ChildProfileRepository` | Firestore dédié |
| Gardiens | `Guardian`, `GuardianId`, activité/cycle | `guardianProvider` | `GuardianRepository` | catalogue local + état enfant Firestore |
| Maison | `HouseState`, pièce, emplacement | `houseProvider` | `HouseRepository` | Firestore dédié |
| Éclats | `ShardWallet`, `RewardLedgerEntry`, `RewardSource` | wallet/award | `RewardsRepository` | transaction ou backend callable |
| Trouvailles | `FindingCatalogItem`, `InventoryEntry`, `Placement` | catalogue/inventaire | `HouseRepository` ou `InventoryRepository` | catalogue asset JSON + Firestore |
| Moteur des Repères | `GuidanceContext`, `Need`, `GuidanceProposal`, `GuidancePair` | orchestration du contexte | `GuidanceRepository`/moteur pur | données locales + historique |
| Missions Secrètes | `SecretMission`, statut, validation | enfant + file parent | `MissionRepository` | Firestore + notification/backend |

### 13.2 Modes d'appareil

- **Téléphone familial** : bootstrap vers espace parent/profils ; sélection d'un enfant ouvre sa Maison ; sortie simple vers parent autorisée selon politique.
- **Tablette personnelle enfant** : `childId` autorisé stocké localement ; ouverture directe Maison ; espace parent toujours verrouillé.
- **Tablette partagée** : liste locale/serveur des enfants autorisés ; sélection puis Maison ; retour vers sélection enfant, jamais dashboard parent.
- Le mode est une propriété de l'installation, donc local. Les enfants autorisés et la politique PIN sont des données familiales synchronisées.
- Prévoir réinitialisation d'appareil, changement de famille, révocation et comportement hors ligne.

### 13.3 PIN parent

- Appui long de 5 secondes sur le logo via un widget unique `ParentAccessGesture`, pas une duplication dans chaque page.
- État verrouillé central observé par GoRouter ; expiration automatique au background et après une durée courte.
- Nombre de tentatives limité, délai progressif, journal minimal sans stocker le PIN.
- Jamais de PIN en clair, jamais de simple comparaison avec une valeur Firestore lisible.
- Le PIN UI ne remplace pas Firebase Auth ni les règles. Comme le client enfant utilise probablement la session Firebase du parent, il ne constitue pas seul une frontière de sécurité serveur.

### 13.4 Maison, Gardiens et inventaire

La Maison doit être un domaine enfant indépendant de `ChildDayProgress`. Un document `house_state` par enfant contient niveau/état et placements ; le catalogue de Trouvailles peut être versionné en JSON local pour éviter des lectures Firestore et garantir prix/rareté stables. L'inventaire persistant contient des IDs de catalogue, quantités, date d'acquisition et placements. L'achat doit être transactionnel : lire solde + catalogue/version autorisée, débiter, créer l'entrée de ledger et l'objet d'inventaire dans la même opération fiable.

Le Gardien sélectionné appartient au profil d'expérience enfant, pas à la Maison. Changer de Gardien ne touche ni maison, ni inventaire, ni solde. Les activités jour/nuit dérivent de l'heure et d'un catalogue déterministe ; ne pas écrire chaque animation en Firestore.

### 13.5 Éclats et anti-triche

Schéma recommandé :

```text
families/{familyId}/children/{childId}/economy/state
families/{familyId}/children/{childId}/reward_ledger/{sourceKey}
```

`sourceKey` est déterministe (`day_2026-07-14`, `mission_<id>`, etc.). Une transaction lit le ledger ; s'il existe, elle ne crédite rien ; sinon elle crée l'entrée et incrémente le solde. Le reset quotidien ne supprime jamais le ledger. Le client ne fournit pas librement le montant : il fournit une source, et une logique de confiance détermine la valeur.

Pour une anti-triche réelle, préférer une fonction backend/transaction de confiance et des règles interdisant l'écriture directe du solde. Une transaction exécutée par un client avec des règles permissives n'empêche pas un client modifié de créditer un montant arbitraire.

### 13.6 Moteur des Repères

Le moteur V1 doit être un composant Dart déterministe, testable sans Firebase. Le provider assemble : enfant, planning du jour, événement courant, progression, vacances, centres d'intérêt, historique et besoin exprimé. Le moteur classe des candidats, applique exclusions/âge/horaire, diversifie, puis retourne un `GuidancePair` contenant exactement deux propositions distinctes. Le Gardien transforme ensuite ces propositions en dialogue selon son ton ; il ne choisit pas la logique métier.

Persister uniquement l'historique utile (IDs proposés/acceptés/refusés, horodatage), avec rétention définie. Les émotions et besoins spécifiques sont des données sensibles : minimisation, visibilité parentale, règles strictes et aucune inférence médicale.

### 13.7 Missions Secrètes

Cycle recommandé : `draft → available → accepted → submitted → approved|rejected → rewarded`. Seul le parent déverrouillé peut créer/valider ; l'enfant peut accepter et soumettre. L'approbation et l'attribution du ledger doivent être dans la même transaction/backend. Un second clic d'approbation est idempotent. Le refus n'efface pas l'historique et n'est jamais formulé de manière culpabilisante.

La notification parent n'a aucun socle actuel : ni FCM ni notifications locales ne sont implémentés. Décider si 15.5 utilise d'abord une file visible dans l'app parent ou ajoute une infrastructure de notifications.

## 14. Plan de migration Sprint 15.1 à 15.5

### Sprint 15.1 — fondation enfant

1. Créer modèles/providers de mode local, enfant actif et verrou parent.
2. Introduire bootstrap testable et gardes GoRouter parent/enfant.
3. Créer `HousePage` minimale et `ChildSelectorPage`.
4. Rattacher `TodayPage` et `ChildRoutinePage` au shell enfant sans modifier leur métier.
5. Ajouter configuration du mode dans paramètres parent et geste logo 5 s.
6. Définir stockage/validation du PIN et tests avant branchement réel.
7. Ajouter règles minimales et tests d'émulateur si la décision de sécurité l'autorise immédiatement.

### Sprint 15.2 — Gardiens

1. Créer catalogue typé des cinq Gardiens et assets optimisés.
2. Créer profil d'expérience enfant et `GuardianRepository`.
3. Ajouter choix/changement libre et souvenir idempotent.
4. Implémenter cycle horaire local et dialogues.
5. Remplacer les usages enfant de la mascotte, notamment fin de journée.

### Sprint 15.3 — Éclats, Trouvailles, progression Maison

1. Créer wallet + ledger idempotent et transaction de crédit.
2. Brancher fin de journée sans dépendre du reset de progression.
3. Créer catalogue de Trouvailles versionné et inventaire.
4. Implémenter achat transactionnel et placements Maison.
5. Ajouter tests concurrence, double clic, reset et reprise multi-appareils.

### Sprint 15.4 — Moteur des Repères

1. Construire `GuidanceContext` depuis les providers existants.
2. Implémenter moteur pur et règle structurelle des deux propositions.
3. Ajouter personnalisation par âge/intérêts/historique.
4. Brancher dialogues Gardien et renouvellement de deux idées.
5. Ajouter tests de ton, diversité, horaire, émotions et sécurité.

### Sprint 15.5 — Missions Secrètes

1. Créer modèle/statuts et repository/service.
2. Créer file parent et présentation enfant.
3. Implémenter validation atomique + ledger Éclats.
4. Ajouter moments partagés/souvenirs.
5. Ajouter notification selon décision d'infrastructure.

## 15. Ordre précis de développement

1. Stabiliser un point Git et capturer les parcours actuels de Ma journée.
2. Ajouter tests de caractérisation pour planning, progression, reset, route `/today` et routine.
3. Définir le modèle de menace du PIN et la décision règles/backend.
4. Créer le stockage local du `DeviceMode` avec migration/version de schéma.
5. Créer les providers de bootstrap, enfant actif et verrou parent.
6. Refactorer GoRouter avec routes nommées, path params, shells et redirects.
7. Créer `ChildSelectorPage` et `HousePage` minimale avec composants existants.
8. Rebrancher `TodayPage`/`ChildRoutinePage` et corriger tous les retours vers la Maison.
9. Ajouter l'écran de configuration appareil et le geste PIN unique.
10. Tester les trois modes, cold start, background, logout, changement de profil et deep links.
11. Livrer 15.2 sans toucher au ledger.
12. Concevoir et tester la transaction/les règles Éclats avant tout affichage de solde.
13. Livrer Trouvailles/Maison persistante.
14. Livrer le moteur déterministe et ses tests exhaustifs.
15. Livrer Missions avec validation parentale atomique.

## 16. Liste des fichiers à modifier pour Sprint 15.1

Liste minimale recommandée ; le périmètre exact dépend des décisions PIN/règles :

- `lib/main.dart` — initialisation du stockage local/bootstrap.
- `lib/routes/app_router.dart` — shells, routes nommées, paramètres et gardes.
- `lib/pages/splash_page.dart` — supprimer le Repository direct et déléguer au bootstrap.
- `lib/pages/dashboard_page.dart` — ouvrir Maison/sélection enfant, conserver accueil parent.
- `lib/pages/today_page.dart` — route enfant, retour Maison, suppression de la fuite `/home`.
- `lib/pages/child_routine_page.dart` — accepter des IDs/path params ou un contexte enfant restaurable.
- `lib/pages/family_settings_page.dart` — accès aux paramètres du mode d'appareil/PIN.
- `lib/providers/session_provider.dart` — seulement si nécessaire pour exposer proprement les transitions Auth ; ne pas y stocker tout le device mode.
- `lib/core/app_assets.dart` — aliases/placeholders Maison et logo d'accès, sans inventer d'assets finaux.
- `lib/core/app_constants.dart` — remplacer la constante PIN chaîne inutilisée par une politique typée, après décision.
- `firebase.json` — référencer rules/indexes si la sécurité minimale est intégrée en 15.1.
- `pubspec.yaml` — **uniquement** si le propriétaire valide une dépendance de stockage sécurisé/backend ; Hive est déjà disponible pour le mode local non secret.

Les fichiers `FamilyRepository` et `FirestoreService` ne devraient pas être modifiés pour accueillir le mode local ou la Maison minimale. Si la configuration famille/PIN exige Firestore, passer par de nouveaux repository/service dédiés.

## 17. Liste des fichiers à créer pour Sprint 15.1

Noms proposés, conformes à l'architecture actuelle :

- `lib/models/device_mode.dart`
- `lib/models/device_configuration_model.dart`
- `lib/models/parent_lock_state.dart`
- `lib/services/device_configuration_service.dart`
- `lib/services/parent_pin_service.dart` ou intégration backend dédiée selon décision
- `lib/repositories/device_access_repository.dart`
- `lib/providers/device_mode_provider.dart`
- `lib/providers/parent_access_provider.dart`
- `lib/providers/app_bootstrap_provider.dart`
- `lib/providers/active_child_provider.dart`
- `lib/pages/child_selector_page.dart`
- `lib/pages/house_page.dart`
- `lib/pages/device_mode_settings_page.dart`
- `lib/pages/parent_unlock_page.dart`
- `lib/widgets/child/house_navigation.dart`
- `lib/widgets/child/parent_access_gesture.dart`
- `lib/widgets/child/house_scene_placeholder.dart`
- `test/models/device_configuration_model_test.dart`
- `test/providers/app_bootstrap_provider_test.dart`
- `test/providers/parent_access_provider_test.dart`
- `test/routes/app_router_test.dart`
- `test/pages/house_page_test.dart`
- `test/pages/today_page_test.dart`
- `firestore.rules` et `firestore.indexes.json` si la sécurité minimale est avancée à 15.1
- tests de règles sous un dossier dédié si l'émulateur Firebase est adopté

Ne pas créer dès 15.1 des repositories vides pour tous les sous-sprints. `GuardianRepository`, `HouseRepository`, `RewardsRepository`, `GuidanceRepository` et `MissionRepository` doivent apparaître au sprint où leur persistance/métier commence réellement.

## 18. Points nécessitant une décision du propriétaire

1. **Sécurité avant ou après Sprint 15** : la roadmap reporte règles et protection des routes, mais les modes enfant et l'anti-triche les rendent nécessaires plus tôt. Recommandation : gardes + règles minimales en 15.1, règles économiques strictes avant 15.3.
2. **Modèle de menace du PIN** : simple barrière UX familiale ou frontière de sécurité forte ? Le choix détermine stockage sécurisé, backend, récupération et fonctionnement hors ligne.
3. **Longueur et récupération du PIN** : la constante technique inutilisée suggère 4 chiffres, mais aucune décision fonctionnelle complète ne le confirme.
4. **Portée du PIN** : unique par famille et synchronisé, ou propre à chaque appareil ? La documentation indique une création au premier appareil enfant mais ne précise pas la réplication.
5. **Identité des adultes** : un profil adulte secondaire peut-il se connecter ? Aujourd'hui seuls l'UID Auth propriétaire et des profils adultes aléatoires coexistent.
6. **Maison 15.1** : placeholder fonctionnel avec fonds existants ou livraison conditionnée aux assets finaux ? Aucun asset Sprint 15 n'est présent.
7. **Mascotte sur welcome** : supprimée partout, conservée comme symbole de marque, ou remplacée par un Gardien choisi ?
8. **Section « Privilèges »** : conserver ce concept pour les moments multiusage, le renommer, ou le fusionner avec les propositions du Gardien ?
9. **Backend anti-triche** : Cloud Functions/callable recommandé, ou transactions client encadrées par rules ? Une sécurité forte est difficile avec un solde modifiable par le client.
10. **Source des prix Trouvailles** : catalogue local versionné signé/contrôlé ou documents Firestore administrables.
11. **Notifications Missions** : file de validation in-app suffisante en V1 ou notification push obligatoire en 15.5 ?
12. **Données sensibles du moteur** : quels besoins spécifiques/humeurs sont réellement stockés, pour combien de temps, et visibles par qui ?
13. **Calendrier scolaire** : compléter les années 2027–2029 maintenant, via données embarquées ou source maintenue.
14. **Cibles plateformes Sprint 15** : Android seulement pendant tests familiaux ou iOS/tablettes inclus immédiatement ? `firebase_options.dart` ne supporte pas iOS actuellement.
15. **Nettoyage avant Sprint** : autoriser un petit chantier séparé pour supprimer doublons/fichiers morts et choisir le thème officiel, afin de ne pas mélanger nettoyage et fonctionnalités.
16. **Stratégie Git** : définir un commit/baseline des nombreux changements actuels avant de créer les fichiers 15.1.

---

Conclusion : le meilleur levier de réutilisation est de préserver intégralement le moteur actuel de « Ma journée » — planning, moments, routines, étapes, événements et progression visuelle — puis de construire autour de lui un véritable shell enfant sécurisé. Le meilleur levier anti-régression est de ne pas étendre les deux monolithes actifs et de rendre les nouveaux invariants (route parent verrouillée, deux propositions, récompense idempotente, validation parentale) impossibles à contourner par construction et par tests.
