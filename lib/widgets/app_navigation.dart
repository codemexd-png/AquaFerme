//ce widget gère la navigation de l'application en utilisant 
//un BottomNavigationBar. Il affiche le widget enfant passé en paramètre et met à jour l'index de navigation en fonction de l'onglet sélectionné. Lorsqu'un onglet est sélectionné, il utilise le package go_router pour naviguer vers la route correspondante.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigation extends StatefulWidget {
  final Widget child;

  const AppNavigation({
    super.key,
    required this.child,
  });

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() => currentIndex = index);

          switch (index) {
            case 0:
              context.go('/home');
              break;

            case 1:
              context.go('/pond-list');
              break;

            case 2:
              context.go('/water-quality');
              break;

            case 3:
              context.go('/planning');
              break;

            case 4:
              context.go('/occupancy');
              break;
          }
        },

        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.water),
            label: 'Étangs',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Qualité',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Planning',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Occupation',
          ),
        ],
      ),
    );
  }
}