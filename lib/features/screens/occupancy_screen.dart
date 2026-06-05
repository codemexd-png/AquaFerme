import 'package:flutter/material.dart';
import '../../widgets/occupation_gauge.dart';
import '../../services/api_service.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/notification_bell.dart';

// ─── Écran Occupation ────────────────────────────────────────────────────────

class OccupancyScreen extends StatefulWidget {
  const OccupancyScreen({super.key});

  @override
  State<OccupancyScreen> createState() => _OccupancyScreenState();
}

class _OccupancyScreenState extends State<OccupancyScreen> {
  late Future<List<dynamic>> _pondsFuture;

  @override
  void initState() {
    super.initState();
    _pondsFuture = ApiService.getPonds();
  }

  void _refresh() {
    setState(() {
      _pondsFuture = ApiService.getPonds();
    });
  }

  Color _colorForPercent(double percent) {
    if (percent >= 90) return Colors.red;
    if (percent >= 70) return Colors.orange;
    if (percent == 0) return Colors.grey;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _pondsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, color: Colors.grey, size: 48),
                const SizedBox(height: 12),
                Text('Erreur de chargement',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final allPonds = snapshot.data!;

        // Séparer barrage et étangs normaux
        final ponds =
            allPonds.where((p) => p['pond_group'] != 'Barrage').toList();
        final barrages =
            allPonds.where((p) => p['pond_group'] == 'Barrage').toList();

        // Calcul stats globales
        int totalFish = 0;
        int totalCapacity = 0;
        for (final p in ponds) {
          totalFish += int.tryParse(p['current_fish_count'].toString()) ?? 0;
          totalCapacity += int.tryParse(p['max_capacity'].toString()) ?? 0;
        }
        final double globalPercent =
            totalCapacity > 0 ? (totalFish / totalCapacity) * 100 : 0;

        // Grouper par pond_group
        final groups = <String, List<dynamic>>{};
        for (final p in ponds) {
          final group = p['pond_group'] as String? ?? '?';
          groups.putIfAbsent(group, () => []).add(p);
        }
        final sortedGroups = groups.keys.toList()..sort();

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Occupation globale ──────────────────────────────────
              _GlobalCard(
                percent: globalPercent,
                totalFish: totalFish,
                totalCapacity: totalCapacity,
              ),

              const SizedBox(height: 18),

              // ── Règle de densité ────────────────────────────────────
              const _DensityCard(),

              const SizedBox(height: 20),

              // ── Sections par groupe ─────────────────────────────────
              ...sortedGroups.map((group) {
                final groupPonds = groups[group]!;
                final areaM2 =
                    int.tryParse(groupPonds.first['area_m2'].toString()) ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      title: 'Étangs $group - $areaM2 m²',
                      color: _groupColor(group),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      itemCount: groupPonds.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.80,
                      ),
                      itemBuilder: (context, i) {
                        final pond = groupPonds[i];
                        final current = int.tryParse(
                                pond['current_fish_count'].toString()) ??
                            0;
                        final max =
                            int.tryParse(pond['max_capacity'].toString()) ?? 0;
                        final double percent =
                            max > 0 ? (current / max) * 100 : 0;
                        return _PondCard(
                          pondId: pond['id'].toString(),
                          name: pond['name'] ?? '${group}${i + 1}',
                          percent: percent,
                          current: current,
                          max: max,
                          color: _colorForPercent(percent),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),

              // ── Barrage ─────────────────────────────────────────────
              if (barrages.isNotEmpty) ...[
                const _SectionTitle(
                  title: 'Barrage',
                  color: Colors.indigo,
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  itemCount: barrages.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.80,
                  ),
                  itemBuilder: (context, i) {
                    final pond = barrages[i];
                    final current =
                        int.tryParse(pond['current_fish_count'].toString()) ??
                            0;
                    final max =
                        int.tryParse(pond['max_capacity'].toString()) ?? 0;
                    final double percent = max > 0 ? (current / max) * 100 : 0;
                    return _PondCard(
                      pondId: pond['id'].toString(),
                      name: pond['name'] ?? 'Barrage',
                      percent: percent,
                      current: current,
                      max: max,
                      color: _colorForPercent(percent),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _groupColor(String group) {
    switch (group) {
      case 'A':
        return Colors.blue;
      case 'B':
        return Colors.green;
      case 'C':
        return Colors.teal;
      case 'D':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

// ─── Carte Globale ───────────────────────────────────────────────────────────

class _GlobalCard extends StatelessWidget {
  final double percent;
  final int totalFish;
  final int totalCapacity;

  const _GlobalCard({
    required this.percent,
    required this.totalFish,
    required this.totalCapacity,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = percent >= 90
        ? Colors.red
        : percent >= 70
            ? Colors.orange
            : Colors.green;

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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    value: percent / 100,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    backgroundColor: const Color(0xFFEAEAEA),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  '${percent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$totalFish poissons au total',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            'Capacité totale : $totalCapacity poissons',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ─── Règle de Densité ────────────────────────────────────────────────────────

class _DensityCard extends StatelessWidget {
  const _DensityCard();

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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('• Densité max : 2,5 poissons/m²',
              style: TextStyle(color: Colors.blue)),
          Text('• Étang 900 m² → max 2250 poissons',
              style: TextStyle(color: Colors.blue)),
          Text('• Étang 600 m² → max 1500 poissons',
              style: TextStyle(color: Colors.blue)),
          Text('• Étang 150 m² → max 375 poissons',
              style: TextStyle(color: Colors.blue)),
          Text('• Étang 400 m² → max 1000 poissons',
              style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}

// ─── Titre Section ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20),
    );
  }
}

// ─── Carte Étang ─────────────────────────────────────────────────────────────

class _PondCard extends StatelessWidget {
  final String pondId;
  final String name;
  final double percent;
  final int current;
  final int max;
  final Color color;

  const _PondCard({
    required this.pondId,
    required this.name,
    required this.percent,
    required this.current,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Afficher juste le code court : "Étang A1" → "A1"
    final shortName = name.replaceAll('Étang ', '');

    return GestureDetector(
      onTap: () => context.push('/pond/$pondId'),
      child: Container(
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
              shortName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            OccupationGauge(
              percent: percent,
              color: color,
              size: 52,
              strokeWidth: 5,
            ),
            const SizedBox(height: 8),
            Text(
              '$current/$max',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page Wrapper ─────────────────────────────────────────────────────────────

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
              'Divine alimentation',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          const NotificationBell(iconColor: Colors.black87),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: const OccupancyScreen(),
    );
  }
}
