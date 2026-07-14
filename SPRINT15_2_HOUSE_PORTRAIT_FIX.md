# Sprint 15.2 — Correction HousePage portrait

## 1. Fichiers modifiés

- `lib/main.dart`
- `lib/core/app_assets.dart`
- `lib/pages/house_page.dart`
- `lib/widgets/child/house_guardian.dart`

`HouseNavigation` et `ParentAccessGesture` ont été vérifiés et réutilisés sans changement pour cette correction. Aucun provider, repository, service, route ou écran extérieur au périmètre n'a été modifié.

## 2. Fichiers créés

- `SPRINT15_2_HOUSE_PORTRAIT_FIX.md`

Aucun widget supplémentaire, aucune dépendance et aucun asset n'ont été créés.

## 3. Stratégie d'affichage du fond

Le fond définitif `assets/images/house/house_background.png` mesure 853 × 1844 pixels. Il est chargé avec `AppAssets.houseBackground` dans la première couche du `Stack`, avec `BoxFit.cover`, un alignement centré et une qualité de filtrage élevée.

Son ratio portrait est proche de celui d'un téléphone moderne. Cette stratégie remplit donc l'écran sans déformation ni bande blanche ou noire et ne provoque qu'un recadrage limité sur téléphone. Sur une tablette portrait plus large, le centrage préserve la porte, la plateforme et la majorité de la scène.

## 4. Stratégie responsive

La composition repose sur un `Stack` plein écran puis une `SafeArea` pour les éléments interactifs. Le contenu utilise un `CustomScrollView` et un `SliverFillRemaining`. Le logo, le Gardien et la navigation partagent ainsi la hauteur disponible sans coordonnées propres à un appareil.

La navigation existante adapte le nombre de colonnes et la largeur de ses cartes à la largeur disponible. Les boutons restent générés par Flutter.

## 5. Positionnement de Crystal

Crystal est affiché dans la zone centrale flexible, entre le logo et la navigation. Il est aligné en bas et au centre de cette zone, ce qui place ses pieds sur ou légèrement au-dessus de la plateforme circulaire du décor.

Le fond et Crystal sont deux widgets `Image.asset` indépendants. Ils ne sont ni fusionnés ni modifiés.

## 6. Taille responsive de Crystal

`HouseGuardian` utilise `BoxFit.contain`. Crystal conserve donc son ratio, sa transparence et reste entièrement contenu dans la zone centrale, sans découpe. La zone grandit sur tablette portrait et se réduit sur téléphone.

Le widget reçoit désormais un `assetPath`, avec `AppAssets.guardianCrystalIdle` comme valeur par défaut. Une autre pose pourra être fournie sans changer la composition de `HousePage`.

## 7. Positionnement du logo

Le logo utilise `AppAssets.logo`. Il est placé en haut à gauche du contenu sûr, dans un conteneur Flutter lisible au-dessus du décor. Il reste distinct du PNG de la Maison et ne recouvre pas Crystal.

## 8. Fonctionnement du maintien 5 secondes

Le logo reste l'enfant direct du widget existant `ParentAccessGesture`. Sa durée par défaut reste exactement de cinq secondes et son accès à `/parent-unlock` n'a pas été modifié ou dupliqué.

## 9. Configuration portrait appliquée

`main.dart` appelle maintenant, après `WidgetsFlutterBinding.ensureInitialized()` et avant Firebase :

```dart
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
]);
```

Le paysage et le portrait inversé ne sont pas autorisés. Les réglages existants des barres système sont conservés.

## 10. Résultat de flutter analyze

`flutter analyze` termine avec **0 problème**.

## 11. Tests exécutés

Le test ciblé `flutter test --no-pub test/widgets/parent_access_gesture_test.dart` a été lancé. Le runner n'a produit aucune sortie et a expiré après 120 secondes, comme lors des vérifications précédentes de cet environnement. Aucun échec de test applicatif n'a donc été observé, mais le test n'a pas pu être exécuté jusqu'à son résultat.

## 12. Vérifications manuelles effectuées

- Présence et chemins réels des trois assets confirmés.
- Dimensions portrait du fond confirmées : 853 × 1844.
- Transparence du PNG de Crystal confirmée.
- Inspection visuelle du fond : aucun texte ni logo intégré.
- Inspection visuelle de Crystal : pose idle indépendante et proportions intactes.
- Conservation de l'accès `Ma journée` vérifiée dans `HouseNavigation`.
- Conservation du maintien de cinq secondes vérifiée dans `ParentAccessGesture`.
- Déclarations des assets dans `pubspec.yaml` confirmées.
- Absence de référence directe aux nouveaux chemins dans `HousePage` confirmée grâce à `AppAssets`.

## 13. Limites éventuelles

Aucun appareil Android n'est exposé dans l'environnement (`adb` indisponible) et le runner Flutter reste bloqué. Le rendu final n'a donc pas pu être contrôlé sur un appareil physique ou un émulateur. La validation responsive repose sur les ratios réels des assets, les contraintes Flutter et l'inspection statique.

## 14. Recommandations avant les autres poses de Crystal

1. Exporter toutes les poses sur un canevas transparent de mêmes dimensions, avec les pieds au même point d'ancrage bas-centre.
2. Déclarer chaque chemin dans `AppAssets`.
3. Passer le chemin voulu à `HouseGuardian` sans ajouter de logique de pose dans `HousePage`.
4. Ajouter des golden tests pour petit téléphone, téléphone standard et tablette portrait dès que le runner Flutter est disponible.
