import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumathisathkam/models/poem.dart';
import 'package:sumathisathkam/services/poem_repository.dart';
import 'package:sumathisathkam/state/favorites_provider.dart';
import 'package:sumathisathkam/screens/poem_detail_screen.dart';
import 'package:sumathisathkam/widgets/gradient_background.dart';

class PoemListScreen extends StatefulWidget {
  const PoemListScreen({super.key});

  @override
  State<PoemListScreen> createState() => _PoemListScreenState();
}

class _PoemListScreenState extends State<PoemListScreen> {
  List<Poem> _poems = [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final poems = await PoemRepository().loadAll();
      if (!mounted) return;
      setState(() {
        _poems = poems;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null)
      return Scaffold(body: Center(child: Text('Error: $_error')));

    return GradientBackground(
      scaffold: true,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Poems'),
            centerTitle: true,
            backgroundColor: Colors
                .transparent, // Allow gradient to show through if desired, or keep theme
            // Use surface tint to distinguish from body
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final poem = _poems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PoemListItem(poem: poem),
                  );
                },
                childCount: _poems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PoemListItem extends StatelessWidget {
  final Poem poem;
  const _PoemListItem({required this.poem});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Flat card style, using border or fill
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PoemDetailScreen(poem: poem))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Number or ID
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${poem.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poem.title ?? poem.snippet,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      poem.snippet,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Favorite Icon
              Consumer<FavoritesProvider>(
                builder: (ctx, fav, _) => IconButton(
                  icon: Icon(
                    fav.isFavorite(poem.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: fav.isFavorite(poem.id)
                        ? Colors.red
                        : Theme.of(context).colorScheme.outline,
                  ),
                  onPressed: () => fav.toggleFavorite(poem.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
