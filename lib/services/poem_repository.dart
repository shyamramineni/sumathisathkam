import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/poem.dart';

class PoemRepository {
  PoemRepository._internal();
  static final PoemRepository _instance = PoemRepository._internal();
  factory PoemRepository() => _instance;

  List<Poem>? _cache;

  /// Load all poems from assets/poems.json. Uses an in-memory cache unless
  /// [forceRefresh] is true.
  Future<List<Poem>> loadAll({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;

    try {
      final jsonText = await rootBundle.loadString('assets/poems.json');
      final data = jsonDecode(jsonText) as List<dynamic>;
      final poems =
          data.map((e) => Poem.fromJson(e as Map<String, dynamic>)).toList();
      _cache = poems;
      return poems;
    } catch (e) {
      // Rethrow a descriptive exception so callers can show UI errors.
      throw Exception('Failed to load poems: $e');
    }
  }

  /// Get a poem by id from cache if available, otherwise loads all poems.
  Future<Poem?> getById(int id) async {
    final list = _cache ?? await loadAll();
    try {
      return list.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear the in-memory cache (useful for testing or refreshing).
  void clearCache() => _cache = null;
}
