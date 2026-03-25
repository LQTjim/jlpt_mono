import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select Language / 選擇語言',
                style: AppTypography.headingMedium(LocaleProvider.localeZh),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _LanguageOption(
                label: 'English',
                locale: LocaleProvider.localeEn,
              ),
              const SizedBox(height: AppSpacing.md),
              _LanguageOption(
                label: '繁體中文',
                locale: LocaleProvider.localeZh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final Locale locale;

  const _LanguageOption({required this.label, required this.locale});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: label,
        variant: AppButtonVariant.outlined,
        size: AppButtonSize.large,
        onPressed: () {
          context.read<LocaleProvider>().setLocale(locale);
        },
      ),
    );
  }
}
