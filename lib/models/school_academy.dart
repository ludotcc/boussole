const defaultSchoolAcademyId = 'non_renseignee';

class SchoolAcademy {
  const SchoolAcademy({
    required this.id,
    required this.label,
    required this.zone,
  });

  final String id;
  final String label;
  final String zone;

  factory SchoolAcademy.fromMap(Map<String, dynamic> map) {
    return SchoolAcademy(
      id: map['id'] as String? ?? defaultSchoolAcademyId,
      label: map['label'] as String? ?? 'Non renseignée',
      zone: map['zone'] as String? ?? '',
    );
  }
}
