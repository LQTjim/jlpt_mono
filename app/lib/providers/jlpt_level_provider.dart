import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum JlptLevel {
  n5('N5'),
  n4('N4'),
  n3('N3'),
  n2('N2'),
  n1('N1');

  final String label;
  const JlptLevel(this.label);
}

class JlptLevelProvider extends ChangeNotifier {
  static const _key = 'jlpt_level';

  JlptLevel _level = JlptLevel.n5;
  bool _isLoaded = false;
  bool _userHasSet = false;

  JlptLevel get level => _level;
  bool get isLoaded => _isLoaded;

  JlptLevelProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userHasSet) return;
    final value = prefs.getString(_key);
    if (value != null) {
      _level = JlptLevel.values.firstWhere(
        (e) => e.name == value,
        orElse: () => JlptLevel.n5,
      );
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLevel(JlptLevel level) async {
    if (_level == level) return;
    _userHasSet = true;
    _level = level;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, level.name);
  }
}
