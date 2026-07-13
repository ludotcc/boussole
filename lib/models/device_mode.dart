enum DeviceMode {
  familyPhone('family_phone'),
  personalChildTablet('personal_child_tablet'),
  sharedChildTablet('shared_child_tablet');

  const DeviceMode(this.value);

  final String value;

  bool get isChildMode => this != DeviceMode.familyPhone;

  String get label => switch (this) {
    DeviceMode.familyPhone => 'Téléphone familial',
    DeviceMode.personalChildTablet => 'Tablette personnelle enfant',
    DeviceMode.sharedChildTablet => 'Tablette partagée',
  };

  String get description => switch (this) {
    DeviceMode.familyPhone =>
      'L’espace parent s’ouvre en premier et chaque enfant peut rejoindre sa Maison.',
    DeviceMode.personalChildTablet =>
      'La Maison d’un enfant s’ouvre directement sur cet appareil.',
    DeviceMode.sharedChildTablet =>
      'Les enfants autorisés choisissent leur profil avant d’ouvrir leur Maison.',
  };

  static DeviceMode fromValue(String? value) {
    return values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => DeviceMode.familyPhone,
    );
  }
}
