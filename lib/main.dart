import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'models/poem.dart';
import 'services/poem_repository.dart';
import 'state/favorites_provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => FavoritesProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    return MaterialApp(
      title: 'Sumathi Sathakam',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        // Base text theme using NTR, then tune key styles for readability
        textTheme: GoogleFonts.ntrTextTheme().copyWith(
          bodyLarge: GoogleFonts.ntr(fontSize: 18, height: 1.4),
          bodyMedium: GoogleFonts.ntr(fontSize: 16, height: 1.3),
          titleLarge: GoogleFonts.ntr(fontSize: 20, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.ntr(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          titleTextStyle: GoogleFonts.ntr(fontSize: 20, fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
          toolbarTextStyle: GoogleFonts.ntr(fontSize: 18, color: colorScheme.onPrimary),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.ntr(fontSize: 16, fontWeight: FontWeight.w600),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      home: const IntroPage(),
    );
  }
}

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  Future<Map<String, dynamic>> _loadIntro() async {
    final jsonText = await rootBundle.loadString('intro.json');
    return jsonDecode(jsonText) as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sumathi Sathakam')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadIntro(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Fallback to the original hardcoded content on error
            final fallbackText =
                'Sumathi Sathakam is a collection of short Telugu poems (sathakam).\n\nEach poem title is the first line in the source text file and the following lines are the poem content. The poems are bundled with the app and shown offline.';
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(fallbackText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PoemListPage()));
                    },
                    child: const Text('View Poems'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? <String, dynamic>{};
          final title = (data['title'] as String?) ?? 'Sumathi Sathakam';
          final text = (data['text'] as String?) ??
              'Sumathi Sathakam is a collection of short Telugu poems (sathakam).\n\nEach poem title is the first line in the source text file and the following lines are the poem content. The poems are bundled with the app and shown offline.';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PoemListPage()));
                  },
                  child: const Text('View Poems'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PoemListPage extends StatelessWidget {
  const PoemListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poems')),
      body: FutureBuilder<List<Poem>>(
        future: PoemRepository().loadAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final poems = snapshot.data ?? [];
          if (poems.isEmpty) {
            return const Center(child: Text('No poems found.'));
          }
          return ListView.separated(
            itemCount: poems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final poem = poems[index];
              return ListTile(
                title: Text(poem.title ?? poem.snippet),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<FavoritesProvider>(
                      builder: (ctx, fav, _) => IconButton(
                        icon: Icon(
                          fav.isFavorite(poem.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: fav.isFavorite(poem.id) ? Colors.red : null,
                        ),
                        onPressed: () => fav.toggleFavorite(poem.id),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PoemPage(poem: poem)));
                },
              );
            },
          );
        },
      ),
    );
  }
}

class PoemPage extends StatelessWidget {
  final Poem poem;
  const PoemPage({super.key, required this.poem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(poem.title ?? poem.snippet),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (ctx, fav, _) => IconButton(
              icon: Icon(
                fav.isFavorite(poem.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: fav.isFavorite(poem.id) ? Colors.red : null,
              ),
              onPressed: () => fav.toggleFavorite(poem.id),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: SingleChildScrollView(
                  child: SelectableText(
                    poem.raw.isNotEmpty ? poem.raw : '(no content)',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 30, height: 1.6),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
