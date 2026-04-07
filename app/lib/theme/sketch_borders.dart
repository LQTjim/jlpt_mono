import 'package:flutter/material.dart';

/// Pre-computed sketch-style border radii used throughout the app.
///
/// [variant] selects from 4 visually distinct hand-drawn shapes.
/// Use [forIndex] to pick a shape deterministically from any integer seed.
abstract final class SketchBorders {
  static const BorderRadius v0 = BorderRadius.only(
    topLeft: Radius.elliptical(14, 18),
    topRight: Radius.elliptical(160, 4),
    bottomRight: Radius.elliptical(10, 22),
    bottomLeft: Radius.elliptical(180, 2),
  );

  static const BorderRadius v1 = BorderRadius.only(
    topLeft: Radius.elliptical(160, 2),
    topRight: Radius.elliptical(12, 20),
    bottomRight: Radius.elliptical(180, 4),
    bottomLeft: Radius.elliptical(14, 16),
  );

  static const BorderRadius v2 = BorderRadius.only(
    topLeft: Radius.elliptical(10, 26),
    topRight: Radius.elliptical(140, 3),
    bottomRight: Radius.elliptical(14, 18),
    bottomLeft: Radius.elliptical(160, 5),
  );

  static const BorderRadius v3 = BorderRadius.only(
    topLeft: Radius.elliptical(140, 4),
    topRight: Radius.elliptical(14, 16),
    bottomRight: Radius.elliptical(160, 2),
    bottomLeft: Radius.elliptical(8, 24),
  );

  static const List<BorderRadius> _all = [v0, v1, v2, v3];

  static BorderRadius forIndex(int index) => _all[index.abs() % 4];
}
