import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

IconData familyEventIcon(String type) {
  return switch (type) {
    'sante' => Icons.favorite_rounded,
    'ecole' => Icons.school_rounded,
    'activite' => Icons.sports_soccer_rounded,
    'famille' => Icons.family_restroom_rounded,
    'anniversaire' => Icons.cake_rounded,
    'rendezVous' => Icons.event_available_rounded,
    _ => Icons.auto_awesome_rounded,
  };
}

Color familyEventColor(String type) {
  return switch (type) {
    'sante' => const Color(0xFFE87393),
    'ecole' => AppColors.primary,
    'activite' => AppColors.turquoise,
    'famille' => AppColors.violet,
    'anniversaire' => AppColors.gold,
    'rendezVous' => AppColors.softOrange,
    _ => AppColors.textSecondary,
  };
}
