import 'package:flutter/material.dart';

class WaterQualityScreen extends StatelessWidget {
  const WaterQualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = [
      {'param': 'Temperature', 'value': '28.0 C', 'status': 'Correct'},
      {'param': 'pH', 'value': '7.2', 'status': 'Correct'},
      {'param': 'Oxygene', 'value': '4.8 mg/L', 'status': 'A surveiller'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Qualite de l eau')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Nouvelle mesure',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Etang',
              hintText: 'Ex: A3',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Temperature (C)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'pH',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Oxygene (mg/L)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {},
            child: const Text('Enregistrer mesure'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Historique recent',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...entries.map(
            (entry) => Card(
              child: ListTile(
                title: Text(entry['param']!),
                subtitle: Text('Valeur: ${entry['value']}'),
                trailing: Text(entry['status']!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
