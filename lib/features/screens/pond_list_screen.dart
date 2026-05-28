import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // 🛰️ Import indispensable pour Consumer

// Widget réutilisable conservé
import '../../widgets/occupation_gauge.dart';
import '../../features/providers/app_providers.dart'; // Ajuste le chemin selon ton dossier providers
import '../../services/api_service.dart';

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
  late Future<List<dynamic>> pondsFuture;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;

    // Appel API : GET /ponds
    pondsFuture = ApiService.getPonds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, _) => Icon(
              provider.isOnSite ? Icons.location_on : Icons.location_off,
              color: provider.isOnSite ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 14),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: FutureBuilder<List<dynamic>>(
        future: pondsFuture,
        builder: (context, snapshot) {
          // Chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Erreur
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur : ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final ponds = snapshot.data ?? [];

          // Filtrage par catégorie
          final filteredPonds = selectedCategory == 'Tous'
              ? ponds
              : ponds
                  .where((pond) => pond['pond_group'] == selectedCategory)
                  .toList();

          final int totalFish = filteredPonds.fold(
            0,
            (sum, pond) => sum + ((pond['current_fish_count'] ?? 0) as int),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Filtres
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
                    '${filteredPonds.length} étangs',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$totalFish poissons',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              ...filteredPonds.map((pond) {
                final int currentFish = pond['current_fish_count'] ?? 0;
                final int maxCapacity = pond['max_capacity'] ?? 1;

                final double percent = maxCapacity > 0
                    ? (currentFish / maxCapacity) * 100
                    : 0.0;

                final Color color = percent >= 90
                    ? Colors.red
                    : percent >= 70
                        ? Colors.orange
                        : Colors.green;

                return _PondCard(
                  id: pond['id'].toString(),
                  name: pond['name'] ?? '',
                  category: pond['pond_group'] ?? '',
                  surface: double.parse(pond['area_m2'].toString()).toInt(),
                  fish: currentFish,
                  weight: 0.0,
                  percent: percent,
                  color: color,
                );
              }),
            ],
          );
        },
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

class _PondCard extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final int surface;
  final int fish;
  final double weight;
  final double percent;
  final Color color;

  const _PondCard({
    required this.id,
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

      // Navigation vers le détail avec l'id réel
      onTap: () {
        context.push('/pond/$id');
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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.startsWith('Étang') ? name : 'Étang $name',
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
                    'Poids moy: ${weight.toStringAsFixed(1)} g',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

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