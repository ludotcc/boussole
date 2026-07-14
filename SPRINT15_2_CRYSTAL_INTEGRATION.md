# Sprint 15.2 — Intégration de la Maison et de Crystal

## Fichiers modifiés

- `lib/pages/house_page.dart` : remplace l'ancien fond et le placeholder par la scène de la Maison et le Gardien.
- `lib/widgets/child/house_navigation.dart` : adapte la largeur et le nombre de colonnes des actions à l'espace disponible.
- `lib/widgets/child/house_scene_placeholder.dart` : supprimé, car le placeholder n'est plus utilisé.
- `pubspec.yaml` : déclare précisément les deux nouveaux assets.

Fichier créé :

- `lib/widgets/child/house_guardian.dart`.

Les PNG fournis n'ont pas été modifiés et aucun nouveau PNG n'a été créé.

## Widget créé

`HouseGuardian` encapsule l'affichage du Gardien. Il reçoit une `CrystalPose`, dont la valeur par défaut est `CrystalPose.idle`. La correspondance entre une pose et son asset reste dans ce widget : une future pose de Crystal pourra donc être ajoutée sans modifier `HousePage`.

## Emplacement choisi pour Crystal

Crystal occupe la zone centrale flexible de la Maison, entre le logo Boussole et les actions de navigation. Il est aligné en bas et au centre de cette zone. Le Gardien est une couche distincte du fond : `house_background.png` et `guardian_crystal_idle.png` sont chargés par deux widgets `Image` indépendants.

## Choix responsive

- Le fond remplit la totalité de l'écran avec `BoxFit.cover`, ce qui conserve son ratio sans déformation.
- Crystal utilise `BoxFit.contain`, conserve son ratio et reste entièrement visible dans la zone disponible.
- La zone du Gardien est flexible : elle grandit sur tablette et se réduit sur téléphone sans taille absolue imposée au personnage.
- La navigation calcule ses colonnes à partir de la largeur disponible, avec des bornes explicites de largeur de carte. Elle évite ainsi de prendre inutilement plusieurs lignes sur les petits écrans.
- La scène respecte les zones sûres et peut défiler si la hauteur disponible devient insuffisante.

## Recommandations avant l'intégration de Pixel

1. Conserver pour Pixel un PNG transparent avec le même cadrage logique et le même point d'ancrage bas-centre que Crystal.
2. Séparer l'identité du Gardien de sa pose avant d'ajouter Pixel, par exemple avec un identifiant de Gardien et un résolveur d'assets par pose. Ne pas ajouter les assets de Pixel dans `CrystalPose`.
3. Normaliser les noms de poses (`idle`, `talking`, `welcome`, `sleeping`) entre tous les Gardiens.
4. Ajouter des golden tests sur au moins un téléphone portrait et une tablette paysage lorsque plusieurs Gardiens seront disponibles.

## Vérification

`flutter analyze` termine sans problème.
