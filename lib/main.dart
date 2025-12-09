import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumathisathkam/state/favorites_provider.dart';
import 'package:sumathisathkam/theme/app_theme.dart';
import 'package:sumathisathkam/screens/home_screen.dart';

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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
