// tool/generate_poems_json.dart

import 'dart:convert';
import 'dart:io';

import '../lib/models/poem.dart';

final _delimiterReg = RegExp(r'॥\s*(\d+)\s*॥');

String _normalizeLineBreaks(String s) {
  // Replace CRLF, CR, U+2028, U+2029 with \n and collapse multiple \n into single \n
  return s.replaceAll(RegExp(r'[\r\u2028\u2029]+'), '\n');
}

List<Poem> parsePoems(String content) {
  content = _normalizeLineBreaks(content).trim();

  final matches = _delimiterReg.allMatches(content).toList();
  final poems = <Poem>[];

  int prevEnd = 0;
  for (final m in matches) {
    final poemRaw = content.substring(prevEnd, m.start).trim();
    final idStr = m.group(1);
    if (poemRaw.isEmpty) {
      prevEnd = m.end;
      continue;
    }
    final lines = poemRaw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final title = lines.isNotEmpty ? lines.first : null;
    final id = idStr != null ? int.tryParse(idStr) ?? -1 : -1;
    poems.add(Poem(id: id, raw: poemRaw, lines: lines, title: title));
    prevEnd = m.end;
  }

  // Handle trailing text after last delimiter (tolerate missing final delimiter)
  if (prevEnd < content.length) {
    final trailing = content.substring(prevEnd).trim();
    if (trailing.isNotEmpty) {
      final lines = trailing.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      final title = lines.isNotEmpty ? lines.first : null;
      poems.add(Poem(id: -1, raw: trailing, lines: lines, title: title));
    }
  }

  return poems;
}

void main(List<String> args) async {
  final inputPath = args.isNotEmpty ? args[0] : 'assets/poems.txt';
  final outputPath = args.length > 1 ? args[1] : 'assets/poems.json';

  final inputFile = File(inputPath);
  if (!await inputFile.exists()) {
    stderr.writeln('Input file not found: $inputPath');
    exit(2);
  }

  final content = await inputFile.readAsString(encoding: utf8);
  final poems = parsePoems(content);

  final jsonList = poems.map((p) => p.toJson()).toList();
  final encoder = JsonEncoder.withIndent('  ');
  await File(outputPath).writeAsString(encoder.convert(jsonList), encoding: utf8);

  stdout.writeln('Parsed ${poems.length} poems and wrote $outputPath');
}
