enum FindingCategory {
  furniture,
  plant,
  light,
  decoration,
  accessory,
  souvenir,
}

enum FindingRarity { common, uncommon, rare }

class FindingCatalogItem {
  const FindingCatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.rarity,
    required this.price,
    required this.iconId,
    required this.colorValue,
  });

  final String id;
  final String name;
  final String description;
  final FindingCategory category;
  final FindingRarity rarity;
  final int price;
  final String iconId;
  final int colorValue;
}
