import 'package:flutter/material.dart';

import 'occupation_gauge.dart';

// Widget réutilisable pour afficher un étang
class PondCard extends StatelessWidget {
  final String name;
  final int surface;
  final int fish;
  final double weight;
  final double percent;
  final Color color;

  const PondCard({
    super.key,
    required this.name,
    required this.surface,
    required this.fish,
    required this.weight,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(

        children: [

          // Icône étang
          Container(

            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: const Color(0xFFE8EEF9),
              borderRadius: BorderRadius.circular(18),
            ),

            child: Center(
              child: Text(
                name.split(' ').last,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Informations
          Expanded(
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$surface m² • $fish poissons',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Poids moy: ${weight.toStringAsFixed(1)} g',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Cercle pourcentage
          OccupationGauge(
            percent: percent,
            color: color,
            size: 62,
            strokeWidth: 5,
          ),
        ],
      ),
    );
  }
}