import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _prefsKey = 'favorites';

  final Set<int> _favorites = {};
  bool _initialized = false;

  FavoritesProvider() {
    _loadFromPrefs();
  }

  bool get initialized => _initialized;

  List<int> get favorites => _favorites.toList();

  bool isFavorite(int id) => _favorites.contains(id);

  Future<void> toggleFavorite(int id) async {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsKey) ?? <String>[];
      _favorites
        ..clear()
        ..addAll(list.map((s) => int.tryParse(s)).whereType<int>());
    } catch (_) {
      // ignore errors and start with empty set
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, _favorites.map((e) => e.toString()).toList());
    } catch (_) {
      // ignore write errors
    }
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {}
  }
}
