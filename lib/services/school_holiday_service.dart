import 'dart:convert';

import 'package:flutter/services.dart';

class SchoolHolidayResult {
  const SchoolHolidayResult({required this.isHoliday, this.holidayName});

  final bool isHoliday;
  final String? holidayName;
}

class SchoolHolidayPeriod {
  const SchoolHolidayPeriod({
    required this.name,
    required this.start,
    required this.end,
  });

  final String name;
  final DateTime start;
  final DateTime end;

  factory SchoolHolidayPeriod.fromMap(Map<String, dynamic> map) {
    return SchoolHolidayPeriod(
      name: map['name'] as String? ?? 'Vacances',
      start: DateTime.parse(map['start'] as String),
      end: DateTime.parse(map['end'] as String),
    );
  }

  bool contains(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    return !day.isBefore(startDay) && !day.isAfter(endDay);
  }
}

class SchoolHolidayService {
  SchoolHolidayService({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  final Map<int, Map<String, List<SchoolHolidayPeriod>>> _cache = {};

  Future<SchoolHolidayResult> holidayFor({
    required DateTime date,
    required String academyId,
  }) async {
    if (academyId.trim().isEmpty || academyId == 'non_renseignee') {
      return const SchoolHolidayResult(isHoliday: false);
    }

    final holidaysByAcademy = await _loadYear(date.year);
    final periods = holidaysByAcademy[academyId] ?? const [];

    for (final period in periods) {
      if (period.contains(date)) {
        return SchoolHolidayResult(isHoliday: true, holidayName: period.name);
      }
    }

    return const SchoolHolidayResult(isHoliday: false);
  }

  Future<Map<String, List<SchoolHolidayPeriod>>> _loadYear(int year) async {
    final cachedYear = _cache[year];

    if (cachedYear != null) {
      return cachedYear;
    }

    try {
      final jsonString = await _assetBundle.loadString(
        'assets/data/school_holidays/$year.json',
      );
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final holidaysByAcademy = <String, List<SchoolHolidayPeriod>>{
        for (final entry in jsonMap.entries)
          entry.key: (entry.value as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(SchoolHolidayPeriod.fromMap)
              .toList(),
      };

      _cache[year] = holidaysByAcademy;

      return holidaysByAcademy;
    } catch (_) {
      _cache[year] = const {};

      return const {};
    }
  }
}
