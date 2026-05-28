import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 🧠 Indispensable pour context.pop()
import 'package:provider/provider.dart'; // 🛰️ Ajouté pour écouter AppProvider

// Widget réutilisable conservé
import '../../features/providers/app_providers.dart'; // Ajuste le chemin selon ton dossier providers

import '../../services/api_service.dart';

class PondDetailScreen extends StatelessWidget {
  final String pondId;

  const PondDetailScreen({
    super.key,
    required this.pondId,
    Map<String, dynamic>? pondData,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOnSite = context.watch<AppProvider>().isOnSite;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        title: const Text(
          'Détail de l’étang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),

      // Ici on appelle le backend : GET /ponds/:id
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getPondById(pondId),
        builder: (context, snapshot) {
          // Chargement pendant l’appel API
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Affichage si l’API retourne une erreur
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur : ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Données reçues depuis le backend
          final pond = snapshot.data!;

          final int id = pond['id'];
          final String name = pond['name'] ?? '';
          final String group = pond['pond_group'] ?? '';
          final int surface = double.parse(pond['area_m2'].toString()).toInt();
          final int capacity = pond['max_capacity'] ?? 0;
          final int fish = pond['current_fish_count'] ?? 0;

          // Calcul du taux d’occupation
          final double percent = capacity > 0 ? (fish / capacity) * 100 : 0;

          // Couleur selon le taux
          final Color color = percent >= 90
              ? Colors.red
              : percent >= 70
                  ? Colors.orange
                  : Colors.green;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Carte principale
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFFEAF2FF),
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.replaceAll('Étang ', ''),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Groupe $group • ID $id',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Badge pourcentage
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
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

                    _InfoRow(label: 'ID', value: '$id'),
                    _InfoRow(label: 'Nom', value: name),
                    _InfoRow(label: 'Groupe', value: group),
                    _InfoRow(label: 'Surface', value: '$surface m²'),
                    _InfoRow(
                      label: 'Capacité maximale',
                      value: '$capacity poissons',
                    ),
                    _InfoRow(
                      label: 'Poissons actuels',
                      value: '$fish poissons',
                    ),
                    _InfoRow(
                      label: 'Taux d’occupation',
                      value: '${percent.toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),

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

  const _InfoRow({
    required this.label,
    required this.value,
  });

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