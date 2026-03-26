import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppTag extends StatelessWidget {
  final String label;
  final Color color;
  const AppTag({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppSpacing.radiusSm,
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
