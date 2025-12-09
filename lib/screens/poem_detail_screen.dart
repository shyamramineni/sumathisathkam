import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumathisathkam/models/poem.dart';
import 'package:sumathisathkam/state/favorites_provider.dart';

class PoemDetailScreen extends StatelessWidget {
  final Poem poem;
  const PoemDetailScreen({super.key, required this.poem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title removed from AppBar
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                poem.title ?? 'Poem ${poem.id}',
                textAlign: TextAlign.center, // Center align the title
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
              ),
              const SizedBox(height: 8), // Small spacing between title and poem
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SelectableText(
                  poem.raw.isNotEmpty ? poem.raw : '(no content)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 26, height: 1.8),
                ),
              ),
              if (poem.meaning != null && poem.meaning!.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'భావం (Meaning)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SelectableText(
                    poem.meaning!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 26,
                          height: 1.8,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implement share or copy later, or just simple Favorite toggle if not in AppBar
          // For now, let's make it a quick "Next" button or similar if context allows,
          // but since I don't have the full list context easily here, maybe "Share" is better?
          // Let's stick to the plan: Focus Mode.
          // Actually, simply hiding FAB for pure reading is better.
          // But I'll put a "Share" placeholder.
        },
        icon: const Icon(Icons.share),
        label: const Text('Share'),
      ),
    );
  }
}
