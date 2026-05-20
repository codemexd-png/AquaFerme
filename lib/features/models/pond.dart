import 'package:flutter/material.dart';

class Pond {
  final String name;       // Ex: "Étang A1"
  final String category;   // Ex: "Élevage", "Alevinage"
  final int surface;       // En m²
  final int fish;          // Nombre de poissons
  final double weight;     // Poids moyen en grammes
  final double percent;    // Taux d'occupation

  // 1. Le constructeur nettoyé (sans la variable 'color')
  Pond({
    required this.name,
    required this.category,
    required this.surface,
    required this.fish,
    required this.weight,
    required this.percent,
  });

  // 2. Le getter calculé : la couleur s'adapte automatiquement selon le pourcentage !
  Color get color {
    if (percent >= 90) {
      return Colors.red;
    } else if (percent > 0) {
      return Colors.orange;
    } else {
      return Colors.green; // Si le taux est à 0%
    }
  }
}