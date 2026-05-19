import 'package:flutter/material.dart';

class MortalityScreen extends StatelessWidget {
  const MortalityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Declaration de mortalite')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Etang',
              hintText: 'Ex: B2',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Nombre de mortalites',
              hintText: 'Ex: 12',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Cause probable',
              hintText: 'Ex: manque d oxygene',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Details',
              hintText: 'Symptomes, actions deja prises',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.warning_amber_rounded),
            label: const Text('Declarer mortalite'),
          ),
        ],
      ),
    );
  }
}
