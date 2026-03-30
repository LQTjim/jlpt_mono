import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_tag.dart';

class GreetingHeader extends StatelessWidget {
  final String name;
  final String? pictureUrl;
  final String jlptLevel;
  final String greeting;

  const GreetingHeader({
    super.key,
    required this.name,
    required this.jlptLevel,
    required this.greeting,
    this.pictureUrl,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage:
              pictureUrl != null ? NetworkImage(pictureUrl!) : null,
          backgroundColor: AppColors.divider,
          child: pictureUrl == null
              ? const Icon(Icons.person, size: 24, color: AppColors.textHint)
              : null,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting$name',
                style: AppTypography.headingSmall(locale),
              ),
              const SizedBox(height: AppSpacing.xs),
              AppTag(label: jlptLevel, color: AppColors.terracotta),
            ],
          ),
        ),
      ],
    );
  }
}
