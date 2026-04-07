import 'package:flutter/material.dart';

class AppTag extends StatelessWidget {
  final String label;
  final Color color;

  const AppTag({super.key, required this.label, required this.color});

  static const _sketchBorder = BorderRadius.only(
    topLeft: Radius.elliptical(10, 16),
    topRight: Radius.elliptical(56, 3),
    bottomRight: Radius.elliptical(14, 18),
    bottomLeft: Radius.elliptical(60, 4),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: _sketchBorder,
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: color,
        ),
      ),
    );
  }
}
