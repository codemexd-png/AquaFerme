import 'package:flutter/material.dart';

class PondDetailScreen extends StatelessWidget {
  // =========================
  // VARIABLES RECUES
  // =========================

  final String name;
  final String category;
  final int surface;
  final int fish;
  final double weight;
  final double percent;
  final Color color;

  const PondDetailScreen({
    super.key,
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
    // =========================
    // CALCUL CAPACITE MAX
    // =========================

    final int capacity = (surface * 2.5).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      // =========================
      // APPBAR
      // =========================

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,

        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // =========================
      // BODY
      // =========================

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          // =========================
          // CARTE PRINCIPALE
          // =========================

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

                // =========================
                // NOM + POURCENTAGE
                // =========================

                Row(
                  children: [

                    // =========================
                    // INFOS ETANG
                    // =========================

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '$category - Grand ($surface m²)',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =========================
                    // BADGE POURCENTAGE
                    // =========================

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),

                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),

                        border: Border.all(
                          color: color,
                          width: 2,
                        ),
                      ),

                      child: Text(
                        '${percent.toInt()}%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Divider(),

                const SizedBox(height: 12),

                // =========================
                // INFORMATIONS
                // =========================

                _InfoRow(
                  label: 'Surface',
                  value: '$surface m²',
                ),

                _InfoRow(
                  label: 'Capacité max',
                  value: '$capacity poissons',
                ),

                const _InfoRow(
                  label: 'Densité max',
                  value: '2.5 poissons/m²',
                ),

                _InfoRow(
                  label: 'Poissons actuels',
                  value: '$fish',
                ),

                _InfoRow(
                  label: 'Poids moyen',
                  value: '${weight.toStringAsFixed(1)} g',
                ),

                _InfoRow(
                  label: 'Taux d’occupation',
                  value: '${percent.toStringAsFixed(1)}%',
                ),

                const _InfoRow(
                  label: 'Dernière MAJ',
                  value: '19/05/2026 10:35',
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =========================
          // MESSAGE GPS
          // =========================

          Container(
            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),

              border: Border.all(
                color: Colors.orange.shade200,
              ),
            ),

            child: const Row(
              children: [

                Icon(
                  Icons.location_off,
                  color: Colors.orange,
                ),

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

          const SizedBox(height: 22),

          // =========================
          // TITRE HISTORIQUE
          // =========================

          const Text(
            'Historique des opérations',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // =========================
          // HISTORIQUE VIDE
          // =========================

          Container(
            height: 130,

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.history,
                    size: 42,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Aucune opération enregistrée',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// WIDGET LIGNE INFO
// =========================

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

          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}