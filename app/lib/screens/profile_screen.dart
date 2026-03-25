import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/jlpt_level_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleProvider>().effectiveLocale;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          if (user != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: user.pictureUrl != null
                        ? NetworkImage(user.pictureUrl!)
                        : null,
                    backgroundColor: AppColors.divider,
                    child: user.pictureUrl == null
                        ? Icon(Icons.person, size: 28, color: AppColors.textHint)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: AppTypography.headingSmall(locale)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(user.email, style: AppTypography.bodyMedium(locale)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
          ],

          _SettingsTile(
            icon: Icons.language,
            title: l10n.language,
            trailing: Text(
              locale == LocaleProvider.localeZh ? l10n.languageChinese : l10n.languageEnglish,
              style: AppTypography.bodyMedium(locale),
            ),
            onTap: () => _showLanguagePicker(context),
          ),

          Consumer<JlptLevelProvider>(
            builder: (context, jlptProvider, _) {
              return _SettingsTile(
                icon: Icons.flag,
                title: l10n.jlptTargetLevel,
                trailing: Text(
                  jlptProvider.level.label,
                  style: AppTypography.bodyMedium(locale),
                ),
                onTap: () => _showJlptLevelPicker(context, jlptProvider),
              );
            },
          ),

          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          _SettingsTile(
            icon: Icons.logout,
            title: l10n.logout,
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: () => auth.signOut(),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();
    final current = localeProvider.effectiveLocale;

    final options = [
      (label: l10n.languageEnglish, locale: LocaleProvider.localeEn),
      (label: l10n.languageChinese, locale: LocaleProvider.localeZh),
    ];

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return _PickerOption(
              label: opt.label,
              selected: current.languageCode == opt.locale.languageCode,
              onTap: () {
                localeProvider.setLocale(opt.locale);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showJlptLevelPicker(BuildContext context, JlptLevelProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: JlptLevel.values.map((level) {
            return _PickerOption(
              label: level.label,
              selected: provider.level == level,
              onTap: () {
                provider.setLevel(level);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                trailing!,
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
              ],
            )
          : null,
      onTap: onTap,
    );
  }
}

class _PickerOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PickerOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check, color: AppColors.terracotta)
          : null,
      onTap: onTap,
    );
  }
}
