import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/providers/app_providers.dart';
import '../../services/api_service.dart';

String calculateAge(String? birthDate) {
  if (birthDate == null || birthDate.isEmpty) return 'Non renseigné';
  final birth = DateTime.parse(birthDate);
  final days = DateTime.now().difference(birth).inDays;
  if (days < 30) return '$days jours';
  if (days < 365) return '${(days / 30).floor()} mois';
  return '${(days / 365).floor()} an(s) ${((days % 365) / 30).floor()} mois';
}

class PondDetailScreen extends StatefulWidget {
  final String pondId;

  const PondDetailScreen({
    super.key,
    required this.pondId,
  });

  @override
  State<PondDetailScreen> createState() => _PondDetailScreenState();
}

class _PondDetailScreenState extends State<PondDetailScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.getPondStats(widget.pondId);
  }

  void _refresh() {
    setState(() {
      _statsFuture = ApiService.getPondStats(widget.pondId);
    });
  }

  Future<void> _showFeedDialog(
      {required double currentGiven, required double currentPlanned}) async {
    final givenController = TextEditingController(
        text: currentGiven > 0 ? currentGiven.toString() : '');
    final plannedController = TextEditingController(
        text: currentPlanned > 0 ? currentPlanned.toString() : '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Saisir la nourriture',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: givenController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Quantité donnée (kg)',
                prefixIcon: const Icon(Icons.set_meal),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: plannedController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Ration prévue (kg)',
                prefixIcon: const Icon(Icons.schedule),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enregistrer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final double? given = double.tryParse(givenController.text.trim());
    final double? planned = double.tryParse(plannedController.text.trim());

    if (given == null || planned == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Veuillez entrer des valeurs valides.'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    try {
      await ApiService.updateDailyFeed(
        pondId: widget.pondId,
        foodGivenKg: given,
        foodPlannedKg: planned,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Nourriture enregistrée ✓'),
              backgroundColor: Colors.green),
        );
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnSite = context.watch<AppProvider>().isOnSite;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        title: const Text(
          'Détail de l\'étang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
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
                  Text('Erreur : ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final pond = snapshot.data!;

          final int id = pond['id'];
          final String name = pond['name'] ?? '';
          final String group = pond['pond_group'] ?? '';
          final int surface = double.parse(pond['area_m2'].toString()).toInt();
          final int capacity = pond['max_capacity'] ?? 0;
          final int fish = pond['current_fish_count'] ?? 0;
          final String? birthDate = pond['birth_date'] as String?;

          final double percent = capacity > 0 ? (fish / capacity) * 100 : 0;

          // Poids moyen
          final double? avgWeight = pond['avg_weight_g'] != null
              ? double.tryParse(pond['avg_weight_g'].toString())
              : null;

          // Ratio nourriture
          final double foodGiven =
              double.tryParse(pond['food_given_kg'].toString()) ?? 0;
          final double foodPlanned =
              double.tryParse(pond['food_planned_kg'].toString()) ?? 0;
          final double foodRatio =
              foodPlanned > 0 ? (foodGiven / foodPlanned).clamp(0.0, 1.0) : 0;

          final Color color = percent >= 90
              ? Colors.red
              : percent >= 70
                  ? Colors.orange
                  : Colors.green;

          final String pondCode = name.replaceAll('Étang ', '');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Carte principale ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // En-tête : avatar + nom + badge
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFFEAF2FF),
                          child: Text(
                            pondCode,
                            style: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Groupe $group • ID $id',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        // Badge pourcentage
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Text(
                            '${percent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Informations techniques
                    _InfoRow(label: 'Surface', value: '$surface m²'),
                    _InfoRow(
                        label: 'Capacité maximale',
                        value: '$capacity poissons'),
                    _InfoRow(
                        label: 'Poissons actuels', value: '$fish poissons'),
                    _InfoRow(
                      label: 'Taux d\'occupation',
                      value: '${percent.toStringAsFixed(1)}%',
                    ),
                    _InfoRow(
                      label: 'Âge des poissons',
                      value: calculateAge(birthDate),
                    ),
                    _InfoRow(
                      label: 'Poids moyen',
                      value: avgWeight != null
                          ? '${avgWeight.toStringAsFixed(1)} g'
                          : 'Non renseigné',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Ratio nourriture ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nourriture du jour',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // ── Bouton saisie nourriture ──────────────
                        ElevatedButton.icon(
                          onPressed: isOnSite
                              ? () => _showFeedDialog(
                                    currentGiven: foodGiven,
                                    currentPlanned: foodPlanned,
                                  )
                              : null,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Saisir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${foodGiven.toStringAsFixed(1)} kg donnés',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '${foodPlanned.toStringAsFixed(1)} kg prévus',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: foodRatio,
                        minHeight: 14,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          foodRatio >= 1.0
                              ? Colors.green
                              : foodRatio >= 0.5
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      foodPlanned > 0
                          ? '${(foodRatio * 100).toStringAsFixed(0)}% de la ration journalière'
                          : 'Aucune ration planifiée pour aujourd\'hui',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Avertissement GPS ─────────────────────────────────
              if (!isOnSite) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_off, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Saisie désactivée : vous devez être sur le site.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // ── Historique ────────────────────────────────────────
              const Text(
                'Historique des opérations',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    'Aucune opération enregistrée',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
