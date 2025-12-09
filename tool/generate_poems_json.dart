import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('assets/poems.txt');
  if (!await file.exists()) {
    print('assets/poems.txt not found');
    return;
  }

  final content = await file.readAsString();
  final lines = content.split('\n');
  final poems = <Map<String, dynamic>>[];

  int? currentId;
  List<String> currentPoemLines = [];
  String? currentTitle;
  String currentMeaning = '';

  // Regex to match ID lines like "001", "110", etc.
  final idRegex = RegExp(r'^\d+$');

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim();
    if (line.isEmpty) continue;

    if (idRegex.hasMatch(line)) {
      // Save previous poem if exists
      if (currentId != null) {
        poems.add({
          'id': currentId,
          'raw': currentPoemLines.join('\n'),
          'lines': currentPoemLines,
          'title': currentTitle,
          'meaning': currentMeaning.trim(),
        });
      }

      // Start new poem
      currentId = int.parse(line);
      currentPoemLines = [];
      currentTitle = null;
      currentMeaning = '';
    } else if (line.startsWith('భావం:')) {
      // It's a meaning line - strip prefix and add to meaning
      // If meaning spans multiple lines, we might need to handle matching subsequent lines
      // But based on input, it seems usually one block at the end.
      // actually, let's just capture everything after "భావం:" as meaning until next ID
      currentMeaning += line.substring('భావం:'.length).trim();
      // Check if there are more lines before next ID?
      // The loop continues. If next line is not ID, it's either more meaning or poem text?
      // The format seems strictly: ID -> Poem Lines -> Meaning -> ID
      // So after encountering meaning, subsequent lines before next ID *could* be meaning continuation.
    } else {
      // It's either poem text or meaning continuation
      if (currentMeaning.isNotEmpty) {
        currentMeaning += ' $line';
      } else {
        // It's a poem line
        currentPoemLines.add(line);
        if (currentTitle == null) {
          currentTitle = line;
        }
      }
    }
  }

  // Add last poem
  if (currentId != null) {
    poems.add({
      'id': currentId,
      'raw': currentPoemLines.join('\n'),
      'lines': currentPoemLines,
      'title': currentTitle,
      'meaning': currentMeaning.trim(),
    });
  }

  final jsonFile = File('assets/poems.json');
  await jsonFile
      .writeAsString(const JsonEncoder.withIndent('  ').convert(poems));
  print('Generated ${poems.length} poems to assets/poems.json');
}
