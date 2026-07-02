import 'package:flutter/material.dart';

import 'app_durations.dart';

class AppAnimation {
  AppAnimation._();

  static const Curve standardCurve = Curves.easeInOut;

  static const Curve emphasizedCurve = Curves.easeOutCubic;

  static const Duration fast = AppDurations.fast;

  static const Duration normal = AppDurations.normal;

  static const Duration slow = AppDurations.slow;
}
