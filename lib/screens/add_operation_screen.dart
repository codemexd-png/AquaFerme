import 'package:flutter/material.dart';

class AddOperationScreen extends StatelessWidget {
  const AddOperationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peche de controle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Informations generales'),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Etang',
              hintText: 'Ex: A5',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Poids moyen (g)',
              hintText: 'Ex: 120',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Nombre echantillonne',
              hintText: 'Ex: 50',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Observation',
              hintText: 'Etat general, comportement, remarques',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save),
            label: const Text('Enregistrer operation'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
