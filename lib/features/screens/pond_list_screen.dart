import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 🧠 Ajouté pour utiliser context.push()

import 'home_screen.dart';
import 'occupancy_screen.dart';
import 'pond_detail_screen.dart';
import '../../widgets/occupation_gauge.dart';

class PondListScreen extends StatefulWidget {
  final String initialCategory;

  const PondListScreen({
    super.key,
    this.initialCategory = 'Tous',
  });

  @override
  State<PondListScreen> createState() => _PondListScreenState();
}

class _PondListScreenState extends State<PondListScreen> {
  late String selectedCategory;

  // Liste temporaire locale sous forme de Maps
  final List<Map<String, dynamic>> ponds = [
    // ================= A =================
    {
      'name': 'Étang A1',
      'category': 'A',
      'surface': 900,
      'fish': 1800,
      'weight': 120.0,
      'percent': 80.0,
      'color': Colors.orange,
    },
    {
      'name': 'Étang A2',
      'category': 'A',
      'surface': 900,
      'fish': 2100,
      'weight': 85.0,
      'percent': 93.0,
      'color': Colors.red,
    },
    {
      'name': 'Étang A3',
      'category': 'A',
      'surface': 900,
      'fish': 1500,
      'weight': 200.0,
      'percent': 67.0,
      'color': Colors.blue,
    },
    {
      'name': 'Étang A4',
      'category': 'A',
      'surface': 900,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },
    {
      'name': 'Étang A5',
      'category': 'A',
      'surface': 900,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },
    {
      'name': 'Étang A6',
      'category': 'A',
      'surface': 900,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },
    {
      'name': 'Étang A7',
      'category': 'A',
      'surface': 900,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },

    // ================= B =================
    {
      'name': 'Étang B1',
      'category': 'B',
      'surface': 600,
      'fish': 1200,
      'weight': 110.0,
      'percent': 80.0,
      'color': Colors.orange,
    },
    {
      'name': 'Étang B2',
      'category': 'B',
      'surface': 600,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },
    {
      'name': 'Étang B3',
      'category': 'B',
      'surface': 600,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },
    {
      'name': 'Étang B4',
      'category': 'B',
      'surface': 600,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },
    {
      'name': 'Étang B5',
      'category': 'B',
      'surface': 600,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },

    // ================= C =================
    {
      'name': 'Étang C1',
      'category': 'C',
      'surface': 150,
      'fish': 300,
      'weight': 90.0,
      'percent': 80.0,
      'color': Colors.orange,
    },
    {
      'name': 'Étang C2',
      'category': 'C',
      'surface': 150,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },
    {
      'name': 'Étang C3',
      'category': 'C',
      'surface': 150,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },

    // ================= D =================
    {
      'name': 'Étang D1',
      'category': 'D',
      'surface': 400,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },
    {
      'name': 'Étang D2',
      'category': 'D',
      'surface': 400,
      'fish': 0,
      'weight': 0.0,
      'percent': 0.0,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPonds = selectedCategory == 'Tous'
        ? ponds
        : ponds.where((pond) => pond['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      // =========================
      // APPBAR SANS FLÈCHE RETOUR
      // =========================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.set_meal, color: Colors.lightBlueAccent),
            SizedBox(width: 8),
            Text(
              'AquaTrack',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.location_off, color: Colors.redAccent),
          SizedBox(width: 14),
          Icon(Icons.settings, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),

      // =========================
      // CONTENU
      // =========================
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FILTRES
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterButton('Tous'),
                _filterButton('A'),
                _filterButton('B'),
                _filterButton('C'),
                _filterButton('D'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedCategory == 'Tous'
                    ? '17 étangs'
                    : 'Étangs $selectedCategory',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '6900 poissons',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ...filteredPonds.map((pond) {
            return _PondCard(
              name: pond['name'],
              category: pond['category'],
              surface: pond['surface'],
              fish: pond['fish'],
              weight: pond['weight'],
              percent: pond['percent'],
              color: pond['color'],
            );
          }),
        ],
      ),

      // =========================
      // TABBAR
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }

          if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OccupancyScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Tableau'),
          BottomNavigationBarItem(icon: Icon(Icons.waves), label: 'Étangs'),
          BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Qualité'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Planning'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: 'Occupation'),
        ],
      ),
    );
  }

  Widget _filterButton(String text) {
    final bool isSelected = selectedCategory == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D47A1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D47A1) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text == 'Tous' ? 'Tous' : 'Catégorie $text',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// =========================
// CARTE ÉTANG
// =========================
class _PondCard extends StatelessWidget {
  final String name;
  final String category;
  final int surface;
  final int fish;
  final double weight;
  final double percent;
  final Color color;

  const _PondCard({
    required this.name,
    required this.category,
    required this.surface,
    required this.fish,
    required this.weight,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pondCode = name.replaceAll('Étang ', '');

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        // Utilisation de GoRouter pour naviguer proprement avec l'identifiant unique
        context.push('/pond/$name', extra: {
          'name': name,
          'category': category,
          'surface': surface,
          'fish': fish,
          'weight': weight,
          'percent': percent,
          'color': color,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // CODE A1, A2, B1...
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  pondCode,
                  style: const TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // INFOS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$surface m² • $fish poissons',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Poids moy: ${weight.toStringAsFixed(1)} g • MAJ: 19/05',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // POURCENTAGE EN ROND
            OccupationGauge(
              percent: percent,
              color: color,
              size: 58,
              strokeWidth: 5,
            ),
          ],
        ),
      ),
    );
  }
}
