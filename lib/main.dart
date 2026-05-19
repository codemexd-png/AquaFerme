import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart'; // 1. Ajoute l'import ici
import 'features/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
  home: HomeScreen();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AquaProject',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme, // 2. Branche le thème ici !
    );
  }
}
