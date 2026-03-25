// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'JLPT Mono';

  @override
  String get signInWithGoogle => '使用 Google 登入';

  @override
  String get welcomeMessage => '歡迎來到 JLPT Mono';

  @override
  String get logout => '登出';

  @override
  String get selectLanguage => '選擇語言';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '繁體中文';

  @override
  String get continueButton => '繼續';

  @override
  String get tabHome => '首頁';

  @override
  String get tabVocabulary => '單字';

  @override
  String get tabQuiz => '測驗';

  @override
  String get tabProfile => '我的';

  @override
  String get profileTitle => '我的';

  @override
  String get language => '語言';

  @override
  String get jlptTargetLevel => 'JLPT 目標等級';

  @override
  String get comingSoon => '即將推出';
}
