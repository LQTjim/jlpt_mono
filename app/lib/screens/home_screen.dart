import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleProvider>().effectiveLocale;
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.signOut(),
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.pictureUrl != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.pictureUrl!),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(user.name, style: AppTypography.headingMedium(locale)),
            const SizedBox(height: AppSpacing.sm),
            Text(user.email, style: AppTypography.bodyMedium(locale)),
            Text(l10n.welcomeMessage, style: AppTypography.bodyLarge(locale)),
          ],
        ),
      ),
    );
  }
}
