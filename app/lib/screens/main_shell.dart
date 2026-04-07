import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'quiz_home_screen.dart';
import 'vocabulary_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      HomeScreen(onNavigateToTab: (i) => setState(() => _currentIndex = i)),
      const VocabularyListScreen(),
      const QuizHomeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _currentIndex,
        onItemTap: (i) => setState(() => _currentIndex = i),
        items: [
          AppNavItemData(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: l10n.tabHome,
          ),
          AppNavItemData(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book,
            label: l10n.tabVocabulary,
          ),
          AppNavItemData(
            icon: Icons.edit_note,
            activeIcon: Icons.edit_note,
            label: l10n.tabQuiz,
          ),
          AppNavItemData(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}

