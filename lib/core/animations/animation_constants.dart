import 'package:flutter/material.dart';

class AppAnimations {
  // Durations
  static const Duration durationShort = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 400);
  static const Duration durationLong = Duration(milliseconds: 600);
  static const Duration durationExtraLong = Duration(milliseconds: 800);

  // Curves
  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveEntrance = Curves.easeOutQuart;
  static const Curve curveExit = Curves.easeInQuart;
  static const Curve curveBounce = Curves.elasticOut;

  // Stagger Delays
  static const Duration staggerDelay = Duration(milliseconds: 50);
}
