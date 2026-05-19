// ─── Composants et constantes partagés entre tous les écrans ────────────────
// Ce fichier regroupe : liste des étangs, décoration de champ, SectionCard,
// FieldRow et ScreenBottomNav. Importer ici évite les imports croisés privés.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─── Liste des étangs ─────────────────────────────────────────────────────────

const etangs = [
  'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8',
  'B1', 'B2', 'B3', 'B4', 'B5',
  'C1', 'C2', 'C3',
  'D1', 'D2',
];

// ─── InputDecoration commune ──────────────────────────────────────────────────

InputDecoration screenInputDecoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1565C0)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );

// ─── SectionCard ─────────────────────────────────────────────────────────────

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── FieldRow ────────────────────────────────────────────────────────────────

class FieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const FieldRow({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: screenInputDecoration(hint),
        ),
      ],
    );
  }
}

// ─── Barre de navigation commune ─────────────────────────────────────────────

class ScreenBottomNav extends StatelessWidget {
  final int currentIndex;

  const ScreenBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1565C0),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      onTap: (index) {
        const routes = [
          null,           // 0 – Tableau de bord (pas encore créé)
          '/mortality',   // 1 – Étangs
          '/water-quality', // 2 – Qualité eau
          '/planning',    // 3 – Planning
          null,           // 4 – Occupation (pas encore créé)
        ];
        final route = routes[index];
        if (route != null) context.go(route);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Tableau de bord',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.water_outlined),
          label: 'Étangs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.water_drop_outlined),
          label: 'Qualité eau',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Planning',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Occupation',
        ),
      ],
    );
  }
}
