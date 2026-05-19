import 'package:flutter/material.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {'day': 'Lundi', 'task': 'Peche de controle A5', 'status': 'En attente'},
      {'day': 'Mercredi', 'task': 'Mesure qualite eau - Etang B', 'status': 'Moyenne'},
      {'day': 'Jeudi', 'task': 'Nettoyage filets etangs C1', 'status': 'Basse'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Planning hebdomadaire')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Semaine du 18 Mai au 24 Mai 2026'),
          ),
          const SizedBox(height: 12),
          ...tasks.map(
            (item) => Card(
              child: ListTile(
                title: Text(item['task']!),
                subtitle: Text(item['day']!),
                trailing: Text(item['status']!),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_task),
        label: const Text('Ajouter tache'),
      ),
    );
  }
}
