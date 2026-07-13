import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/school_academy.dart';

class AcademyService {
  AcademyService({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  List<SchoolAcademy>? _academies;

  Future<List<SchoolAcademy>> getAcademies() async {
    final cachedAcademies = _academies;

    if (cachedAcademies != null) {
      return cachedAcademies;
    }

    final jsonString = await _assetBundle.loadString(
      'assets/data/french_academies.json',
    );
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    final academies = jsonList
        .whereType<Map<String, dynamic>>()
        .map(SchoolAcademy.fromMap)
        .toList();

    _academies = academies;

    return academies;
  }

  Future<SchoolAcademy?> getAcademyById(String academyId) async {
    final academies = await getAcademies();

    for (final academy in academies) {
      if (academy.id == academyId) {
        return academy;
      }
    }

    return null;
  }

  Future<String> labelFor(String academyId) async {
    final academy = await getAcademyById(academyId);

    return academy?.label ?? 'Non renseignée';
  }

  Future<String?> zoneFor(String academyId) async {
    final academy = await getAcademyById(academyId);

    return academy?.zone;
  }

  Future<String> normalizeAcademyId(String academyId) async {
    final academy = await getAcademyById(academyId);

    return academy?.id ?? defaultSchoolAcademyId;
  }
}
