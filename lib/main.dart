// ─── Point d'entrée de l'application AquaFerme ──────────────────────────────
// AppProvider est injecté ici pour être accessible dans tout l'arbre de widgets.
// Le routage est géré par GoRouter (appRouter) défini dans core/navigation/.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/providers/app_providers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp.router(
        title: 'AquaProject',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme.lightTheme,
      ),
    );
  }   
}
