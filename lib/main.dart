import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle, RawKeyDownEvent, LogicalKeyboardKey;

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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PoemListView()));
                          },
                          child: const Text('List View'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PoemCarouselView()));
                          },
                          child: const Text('Carousel View'),
                        ),
                      ),
                    ],
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PoemListView()));
                        },
                        child: const Text('List View'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PoemCarouselView()));
                        },
                        child: const Text('Carousel View'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PoemListPage extends StatefulWidget {
  const PoemListPage({super.key});

  @override
  _PoemListPageState createState() => _PoemListPageState();
}

class _PoemListPageState extends State<PoemListPage> {
  final PageController _pageController = PageController();
  List<Poem> _poems = [];
  bool _loading = true;
  Object? _error;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPoems();
  }

  Future<void> _loadPoems() async {
    try {
      final poems = await PoemRepository().loadAll();
      if (!mounted) return;
      setState(() {
        _poems = poems;
        _loading = false;
        _currentIndex = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _jumpTo(int index) {
    if (_poems.isEmpty) return;
    final safe = (index % _poems.length + _poems.length) % _poems.length;
    _pageController.jumpToPage(safe);
    setState(() => _currentIndex = safe);
  }

  void _nextWrap() => _jumpTo(_currentIndex + 1);
  void _prevWrap() => _jumpTo(_currentIndex - 1);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poems')),
      body: Builder(builder: (context) {
        if (_loading) return const Center(child: CircularProgressIndicator());
        if (_error != null) return Center(child: Text('Error: $_error'));
        if (_poems.isEmpty) return const Center(child: Text('No poems found.'));

        return SafeArea(
          child: Focus(
            autofocus: true,
            onKey: (node, event) {
              if (event is RawKeyDownEvent) {
                final key = event.logicalKey;
                if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.space) {
                  _nextWrap();
                  return KeyEventResult.handled;
                }
                if (key == LogicalKeyboardKey.arrowLeft) {
                  _prevWrap();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _poems.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, index) {
                    final poem = _poems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 6,
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(poem.title ?? poem.snippet, style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 12),
                                    SelectableText(
                                      poem.raw.isNotEmpty ? poem.raw : '(no content)',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 30, height: 1.6),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PoemPage(poem: poem)));
                                          },
                                          child: const Text('Open'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Previous button (wraps)
                Positioned(
                  left: 8,
                  child: IconButton(
                    iconSize: 36,
                    tooltip: 'Previous',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _prevWrap,
                  ),
                ),

                // Next button (wraps)
                Positioned(
                  right: 8,
                  child: IconButton(
                    iconSize: 36,
                    tooltip: 'Next',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextWrap,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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

class PoemListView extends StatefulWidget {
  const PoemListView({super.key});

  @override
  State<PoemListView> createState() => _PoemListViewState();
}

class _PoemListViewState extends State<PoemListView> {
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
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text('Error: $_error')));
    return Scaffold(
      appBar: AppBar(title: const Text('Poems - List')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _poems.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final poem = _poems[index];
          return ListTile(
            title: Text(poem.title ?? poem.snippet),
            subtitle: Text(poem.snippet),
            trailing: Consumer<FavoritesProvider>(
              builder: (ctx, fav, _) => IconButton(
                icon: Icon(fav.isFavorite(poem.id) ? Icons.favorite : Icons.favorite_border, color: fav.isFavorite(poem.id) ? Colors.red : null),
                onPressed: () => fav.toggleFavorite(poem.id),
              ),
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PoemPage(poem: poem))),
          );
        },
      ),
    );
  }
}

class PoemCarouselView extends StatelessWidget {
  const PoemCarouselView({super.key});

  @override
  Widget build(BuildContext context) => const PoemListPage();
}
