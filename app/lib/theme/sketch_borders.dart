import 'package:flutter/material.dart';

/// Pre-computed sketch-style border radii used throughout the app.
///
/// [variant] selects from 4 visually distinct hand-drawn shapes.
/// Use [forIndex] to pick a shape deterministically from any integer seed.
abstract final class SketchBorders {
  static const BorderRadius v0 = BorderRadius.only(
    topLeft: Radius.elliptical(14, 180),
    topRight: Radius.elliptical(160, 4),
    bottomRight: Radius.elliptical(100, 22),
    bottomLeft: Radius.elliptical(180, 2),
  );

  static const BorderRadius v1 = BorderRadius.only(
    topLeft: Radius.elliptical(160, 20),
    topRight: Radius.elliptical(12, 150),
    bottomRight: Radius.elliptical(180, 34),
    bottomLeft: Radius.elliptical(170, 26),
  );

  static const BorderRadius v2 = BorderRadius.only(
    topLeft: Radius.elliptical(10, 150),
    topRight: Radius.elliptical(140, 13),
    bottomRight: Radius.elliptical(14, 180),
    bottomLeft: Radius.elliptical(160, 5),
  );

  static const BorderRadius v3 = BorderRadius.only(
    topLeft: Radius.elliptical(140, 4),
    topRight: Radius.elliptical(140, 16),
    bottomRight: Radius.elliptical(160, 2),
    bottomLeft: Radius.elliptical(8, 150),
  );

  static const List<BorderRadius> _all = [v0, v1, v2, v3];

  static BorderRadius forIndex(int index) => _all[index.abs() % 4];
}
