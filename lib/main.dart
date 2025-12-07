import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return MaterialApp(
      title: 'Sumathi Sathakam',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const IntroPage(),
    );
  }
}

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sumathi Sathakam')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sumathi Sathakam is a collection of short Telugu poems (sathakam).\n\nEach poem title is the first line in the source text file and the following lines are the poem content. The poems are bundled with the app and shown offline.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PoemListPage()));
              },
              child: const Text('View Poems'),
            ),
          ],
        ),
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
                          fav.isFavorite(poem.id) ? Icons.favorite : Icons.favorite_border,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(poem.title ?? poem.snippet),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (ctx, fav, _) => IconButton(
              icon: Icon(
                fav.isFavorite(poem.id) ? Icons.favorite : Icons.favorite_border,
                color: fav.isFavorite(poem.id) ? Colors.red : null,
              ),
              onPressed: () => fav.toggleFavorite(poem.id),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText(
          poem.raw.isNotEmpty ? poem.raw : '(no content)',
          style: const TextStyle(fontSize: 18, height: 1.4),
        ),
      ),
    );
  }
}
