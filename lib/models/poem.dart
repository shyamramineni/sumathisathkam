// lib/models/poem.dart

import 'dart:convert';

class Poem {
  final int id;
  final String raw;
  final List<String> lines;
  final String? title;

  final String? meaning;

  Poem({
    required this.id,
    required this.raw,
    required this.lines,
    this.title,
    this.meaning,
  });

  // Create a Poem from a decoded JSON map
  factory Poem.fromJson(Map<String, dynamic> json) {
    final raw = json['raw'] as String? ?? '';
    final lines =
        (json['lines'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            (raw.isNotEmpty ? raw.split('\n') : <String>[]);
    return Poem(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      raw: raw,
      lines: lines,
      title: json['title'] as String?,
      meaning: json['meaning'] as String?,
    );
  }

  // Short snippet usable in list items
  String get snippet {
    if (lines.isNotEmpty) return lines.first;
    if (raw.isNotEmpty) return raw.split('\n').first;
    return '';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'raw': raw,
        'lines': lines,
        'title': title,
        'meaning': meaning,
      };

  @override
  String toString() => jsonEncode(toJson());
}
