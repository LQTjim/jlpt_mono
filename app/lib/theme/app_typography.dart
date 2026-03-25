import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  // ---------------------------------------------------------------------------
  // UI 字型 — 依語系切換 TC / JP
  // ---------------------------------------------------------------------------

  static TextStyle headingLarge(Locale locale) => _sans(locale,
      fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle headingMedium(Locale locale) => _sans(locale,
      fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle headingSmall(Locale locale) => _sans(locale,
      fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle bodyLarge(Locale locale) => _sans(locale,
      fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  static TextStyle bodyMedium(Locale locale) => _sans(locale,
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  static TextStyle bodySmall(Locale locale) => _sans(locale,
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textHint);

  static TextStyle labelLarge(Locale locale) => _sans(locale,
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle button(Locale locale) => _sans(locale,
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);

  // ---------------------------------------------------------------------------
  // 內容字型 — 固定 JP（單字、例句）
  // ---------------------------------------------------------------------------

  static TextStyle get contentHeading => _serifFonts.jp(
      fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle get contentBody => GoogleFonts.notoSansJp(
      fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  static TextStyle get contentCaption => GoogleFonts.notoSansJp(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static TextStyle _withFallback(
    Locale locale, {
    required _FontPair fonts,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    final isZh = locale.languageCode == 'zh';
    final primary = isZh ? fonts.tc : fonts.jp;
    final fallback = isZh ? fonts.jp : fonts.tc;
    final style = primary(fontSize: fontSize, fontWeight: fontWeight, color: color);
    return style.copyWith(
      fontFamilyFallback: [fallback().fontFamily!, ...?style.fontFamilyFallback],
    );
  }

  static TextStyle _sans(
    Locale locale, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) =>
      _withFallback(locale,
          fonts: _sansFonts, fontSize: fontSize, fontWeight: fontWeight, color: color);

  static final _sansFonts = _FontPair(GoogleFonts.notoSansTc, GoogleFonts.notoSansJp);
  static final _serifFonts = _FontPair(GoogleFonts.notoSerifTc, GoogleFonts.notoSerifJp);
}

typedef _GoogleFontBuilder = TextStyle Function({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
});

class _FontPair {
  final _GoogleFontBuilder tc;
  final _GoogleFontBuilder jp;
  const _FontPair(this.tc, this.jp);
}
