import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool scaffold;
  final AppBar? appBar;
  final Widget? floatingActionButton;

  const GradientBackground({
    super.key,
    required this.child,
    this.scaffold = false,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    // Define gradient colors derived from theme or custom warm palette
    final colorScheme = Theme.of(context).colorScheme;

    // Using a subtle top-down gradient
    // Top: lighter/warmer tone (like a sun wash)
    // Bottom: standard background or slightly darker

    // Gradient definition
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        // Combining primaryContainer with surface for a tinted look
        // or hardcoding some nice warm pastel hexes if strictly requested,
        // but using theme is safer for dark mode support later.

        // Let's try mixing surface with a bit of primary container
        Color.alphaBlend(colorScheme.primaryContainer.withOpacity(0.15),
            colorScheme.surface),
        colorScheme.surface,
        Color.alphaBlend(colorScheme.tertiaryContainer.withOpacity(0.1),
            colorScheme.surface),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    if (scaffold) {
      return Scaffold(
        extendBodyBehindAppBar:
            true, // Allow gradient to show behind app bar if transparent
        appBar: appBar,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: gradient),
          child:
              child, // Don't SafeArea here if we want full screen gradient, handle inside child or specific parts
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
