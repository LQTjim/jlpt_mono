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

  @override
  String get tabHome => 'Home';

  @override
  String get tabVocabulary => 'Vocabulary';

  @override
  String get tabQuiz => 'Quiz';

  @override
  String get tabProfile => 'Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get jlptTargetLevel => 'JLPT Target Level';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get searchHint => 'Search words...';

  @override
  String get allLevels => 'All Levels';

  @override
  String get noWordsFound => 'No words found';

  @override
  String get examples => 'Examples';

  @override
  String get relatedWords => 'Related Words';

  @override
  String get synonym => 'Synonym';

  @override
  String get antonym => 'Antonym';

  @override
  String get related => 'Related';

  @override
  String get retry => 'Retry';

  @override
  String get errorLoadingWords => 'Failed to load words';
}
