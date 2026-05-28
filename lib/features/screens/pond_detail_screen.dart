import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 🧠 Indispensable pour context.pop()
import 'package:provider/provider.dart'; // 🛰️ Ajouté pour écouter AppProvider

// Widget réutilisable conservé
import '../../widgets/stat_card.dart';
import '../../features/providers/app_providers.dart'; // Ajuste le chemin selon ton dossier providers

// Fonction utilitaire pour calculer l'âge d'un poisson à partir de sa date de naissance
String calculateAge(String? birthDate) {
  if (birthDate == null || birthDate.isEmpty) return 'Non renseigné';
  final birth = DateTime.parse(birthDate);
  final days = DateTime.now().difference(birth).inDays;
  if (days < 30) return '$days jours';
  if (days < 365) return '${(days / 30).floor()} mois';
  return '${(days / 365).floor()} an(s) ${((days % 365) / 30).floor()} mois';
}

class PondDetailScreen extends StatelessWidget {
  // =========================
  // VARIABLES REÇUES
  // =========================
  final String pondId;
  final Map<String, dynamic>? pondData;

  const PondDetailScreen({
    super.key,
    required this.pondId,
    this.pondData,
  });

  @override
  Widget build(BuildContext context) {
    // Écoute dynamique de l'état de géolocalisation globale
    final bool isOnSite = context.watch<AppProvider>().isOnSite;

    // 🛡️ Sécurité essentielle : évite le crash si la Map est nulle
    if (pondData == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D47A1),
          title: const Text('Erreur'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Étang introuvable ou données manquantes.',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    // Extraction des données de la Map locale
    final name = pondData!['name'] as String;
    final category = pondData!['category'] as String;
    final surface = pondData!['surface'] as int;
    final fish = pondData!['fish'] as int;
    final weight = pondData!['weight'] as double;
    final percent = pondData!['percent'] as double;

    // Calcul de la couleur à la volée selon le pourcentage
    Color color;
    if (percent >= 90) {
      color = Colors.red;
    } else if (percent > 0) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    // =========================
    // CALCUL CAPACITÉ MAX
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
            context.pop();
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
                            'Catégorie $category - Grand ($surface m²)',
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
                // INFORMATIONS TECHNIQUES
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
                _InfoRow(
                  label: 'Âge des poissons',
                  value: calculateAge(pondData!['birth_date'] as String?),
                ),
                const _InfoRow(
                  label: 'Dernière MAJ',
                  value: '19/05/2026 10:35',
                ),
              ],
            ),
          ),

          // ===================================================================
          // MESSAGE GPS DYNAMIQUE
          // S'affiche uniquement si l'employé n'est pas physiquement à la ferme
          // ===================================================================
          if (!isOnSite) ...[
            const SizedBox(height: 18),
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
          ],

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
