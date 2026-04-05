import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/audio_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/flashcard_provider.dart';
import 'providers/jlpt_level_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/vocabulary_provider.dart';
import 'screens/language_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/api_client.dart';
import 'services/audio_service.dart';
import 'services/auth_service.dart';
import 'services/dashboard_service.dart';
import 'services/quiz_service.dart';
import 'services/vocabulary_service.dart';
import 'theme/app_theme.dart';
import 'widgets/debug_overlay.dart';

void main() {
  final authService = AuthService();
  late final AuthProvider authProvider;
  final apiClient = ApiClient(
    authService,
    onAuthFailure: () => authProvider.signOut(),
  );
  authProvider = AuthProvider(
    authService: authService,
    apiClient: apiClient,
  )..tryAutoLogin();

  runApp(MyApp(
    authProvider: authProvider,
    apiClient: apiClient,
  ));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final ApiClient apiClient;

  const MyApp({
    super.key,
    required this.authProvider,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => JlptLevelProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => VocabularyProvider(VocabularyService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(QuizService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(DashboardService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioProvider(AudioService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => FlashcardProvider(VocabularyService(apiClient)),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'JLPT Mono',
            theme: AppTheme.light,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => DebugOverlay(child: child!),
            home: _buildHome(context, localeProvider),
          );
        },
      ),
    );
  }

  Widget _buildHome(BuildContext context, LocaleProvider localeProvider) {
    if (!localeProvider.isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!localeProvider.hasLocale) {
      return const LanguageSelectionScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return auth.isAuthenticated ? const MainShell() : const LoginScreen();
      },
    );
  }
}
