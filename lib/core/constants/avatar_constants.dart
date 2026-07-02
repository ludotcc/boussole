class AvatarItem {
  final String id;
  final String asset;

  const AvatarItem({required this.id, required this.asset});
}

class AvatarConstants {
  static const List<AvatarItem> avatars = [
    AvatarItem(id: 'papa', asset: 'assets/images/avatars/papa.png'),
    AvatarItem(id: 'maman', asset: 'assets/images/avatars/maman.png'),
    AvatarItem(id: 'frere', asset: 'assets/images/avatars/frere.png'),
    AvatarItem(id: 'soeur', asset: 'assets/images/avatars/soeur.png'),
    AvatarItem(id: 'baby_boy', asset: 'assets/images/avatars/baby_boy.png'),
    AvatarItem(id: 'baby_girl', asset: 'assets/images/avatars/baby_girl.png'),
  ];

  static String assetFromId(String id) {
    return avatars.firstWhere((e) => e.id == id).asset;
  }
}
