// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'JLPT Mono';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get welcomeMessage => 'Welcome to JLPT Mono';

  @override
  String get logout => 'Log out';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '繁體中文';

  @override
  String get continueButton => 'Continue';
}
