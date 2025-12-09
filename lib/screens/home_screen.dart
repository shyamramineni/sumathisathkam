import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sumathisathkam/screens/poem_list_screen.dart';
import 'package:sumathisathkam/widgets/gradient_background.dart';
// Note: We need to handle the case where PoemDetailScreen or Carousel isn't created yet,
// but based on the plan, we will create them. For now, I'll refer to them.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _introData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadIntro();
  }

  Future<void> _loadIntro() async {
    try {
      final jsonText = await rootBundle.loadString('assets/intro.json');
      // Note: original code used 'intro.json', but pubspec says 'assets/intro.json'.
      // The original code was `rootBundle.loadString('intro.json')`, which implies it was at root assets?
      // Checking pubspec: assets: - assets/intro.json. So it should be 'assets/intro.json'.
      // Wait, original main.dart had: rootBundle.loadString('intro.json');
      // If that worked, maybe the asset key was just 'intro.json' in pubspec?
      // Let's check the pubspec content again from my memory/previous turn.
      // Pubspec said:
      // flutter:
      //   assets:
      //     - assets/poems.txt
      //     - assets/poems.json
      //     - assets/intro.json
      // Usually you load with the full path 'assets/intro.json'.
      // I will use 'assets/intro.json' to be safe, or try-catch.

      final data = jsonDecode(jsonText) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _introData = data;
          _loading = false;
        });
      }
    } catch (e) {
      // Fallback if loading fails or file path is different in a way I can't guess without running
      // Try loading without 'assets/' prefix if that was the issue, but unlikely given standard flutter logic.
      // For now, just show default content.
      debugPrint('Error loading intro: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final title = _introData?['title'] as String? ?? 'Sumathi Sathakam';
    final text = _introData?['text'] as String? ??
        'Sumathi Sathakam is a collection of short Telugu poems (sathakam) known for their moral values and simplicity.';

    return GradientBackground(
      scaffold: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Hero Section
              Center(
                child: Text(
                  'సుమతీ శతకం', // Telugu Title
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 48),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[
                          700]), // Darker grey for legibility on colored bg
                ),
              ),
              const SizedBox(height: 48),

              // Description
              Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const Spacer(),

              // Actions
              _HomeButton(
                icon: Icons.list_alt_rounded,
                label: 'Start Reading',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const PoemListScreen()));
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface, // Use surface color
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.arrow_forward_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
