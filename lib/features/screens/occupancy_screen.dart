import 'package:flutter/material.dart';
import '../../widgets/occupation_gauge.dart';
import 'package:go_router/go_router.dart';

// ─── Écran Contenu Seul ──────────────────────────────────────────────────────
// Contient la liste et les grilles d'occupation. Idéal pour être appelé dans ton index principal.
class OccupancyScreen extends StatelessWidget {
  const OccupancyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        // =========================
        // OCCUPATION GLOBALE
        // =========================
        GlobalCard(),

        SizedBox(height: 18),

        // =========================
        // REGLE
        // =========================
        DensityCard(),

        SizedBox(height: 20),

        // =========================
        // ETANGS A
        // =========================
        SectionTitle(
          title: 'Étangs A - 900 m²',
          color: Colors.blue,
        ),

        SizedBox(height: 12),

        PondGrid(
          ponds: [
            ['A1', 80, 1800, 2250, Colors.orange],
            ['A2', 93, 2100, 2250, Colors.red],
            ['A3', 67, 1500, 2250, Colors.blue],
            ['A4', 0, 0, 2250, Colors.green],
            ['A5', 0, 0, 2250, Colors.green],
            ['A6', 0, 0, 2250, Colors.green],
          ],
        ),

        SizedBox(height: 20),

        // =========================
        // ETANGS B
        // =========================
        SectionTitle(
          title: 'Étangs B - 600 m²',
          color: Colors.green,
        ),

        SizedBox(height: 12),

        PondGrid(
          ponds: [
            ['B1', 80, 1200, 1500, Colors.orange],
            ['B2', 0, 0, 1500, Colors.green],
            ['B3', 0, 0, 1500, Colors.green],
            ['B4', 0, 0, 1500, Colors.green],
            ['B5', 0, 0, 1500, Colors.green],
          ],
        ),

        SizedBox(height: 20),

        // =========================
        // ETANGS C
        // =========================
        SectionTitle(
          title: 'Étangs C - 150 m²',
          color: Colors.green,
        ),

        SizedBox(height: 12),

        PondGrid(
          ponds: [
            ['C1', 80, 300, 375, Colors.orange],
            ['C2', 0, 0, 375, Colors.green],
            ['C3', 0, 0, 375, Colors.green],
          ],
        ),

        SizedBox(height: 20),

        // =========================
        // ETANGS D
        // =========================
        SectionTitle(
          title: 'Étangs D - 400 m²',
          color: Colors.indigo,
        ),

        SizedBox(height: 12),

        PondGrid(
          ponds: [
            ['D1', 0, 0, 1000, Colors.green],
            ['D2', 0, 0, 1000, Colors.green],
          ],
        ),

        SizedBox(height: 20),
      ],
    );
  }
}

// ─── Carte Globale ───────────────────────────────────────────────────────────
class GlobalCard extends StatelessWidget {
  const GlobalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Taux d'occupation global",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 0.24,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    backgroundColor: const Color(0xFFEAEAEA),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                  ),
                ),
                const Text(
                  '24%',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '6900 poissons au total',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Capacité totale: 26375 poissons',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Règle de Densité ────────────────────────────────────────────────────────
class DensityCard extends StatelessWidget {
  const DensityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Règle de densité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '• Densité max: 2,5 poissons/m²',
            style: TextStyle(color: Colors.blue),
          ),
          Text(
            '• Étang 900 m² → max 2250 poissons',
            style: TextStyle(color: Colors.blue),
          ),
          Text(
            '• Étang 600 m² → max 1500 poissons',
            style: TextStyle(color: Colors.blue),
          ),
          Text(
            '• Étang 150 m² → max 375 poissons',
            style: TextStyle(color: Colors.blue),
          ),
          Text(
            '• Étang 400 m² → max 1000 poissons',
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

// ─── Titre Section ───────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const SectionTitle({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }
}

// ─── Grille des Étangs ───────────────────────────────────────────────────────
class PondGrid extends StatelessWidget {
  final List<List<dynamic>> ponds;

  const PondGrid({
    super.key,
    required this.ponds,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: ponds.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.80,
      ),
      itemBuilder: (context, index) {
        final pond = ponds[index];
        return PondCard(
          name: pond[0],
          percent: pond[1],
          current: pond[2],
          max: pond[3],
          color: pond[4],
        );
      },
    );
  }
}

// ─── Carte Étang Unitaire ────────────────────────────────────────────────────
class PondCard extends StatelessWidget {
  final String name;
  final int percent;
  final int current;
  final int max;
  final Color color;

  const PondCard({
    super.key,
    required this.name,
    required this.percent,
    required this.current,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          OccupationGauge(
            percent: percent.toDouble(),
            color: color,
            size: 52,
            strokeWidth: 5,
          ),
          const SizedBox(height: 8),
          Text(
            '$current/$max',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page Wrapper (Scaffold + AppBar) ────────────────────────────────────────

class OccupancyPage extends StatelessWidget {
  const OccupancyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.set_meal, color: Color(0xFF1565C0), size: 26),
            SizedBox(width: 6),
            Text(
              'AquaTrack',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: const OccupancyScreen(),
    );
  }
}
