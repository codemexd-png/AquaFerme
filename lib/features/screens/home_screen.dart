import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 🧠 Ajouté pour centraliser toute la navigation

// Widget réutilisable conservé
import '../../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      // =========================
      // BARRE DU HAUT
      // =========================
      appBar: AppBar(
        automaticallyImplyLeading: false, // Enlève la flèche retour
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.set_meal, color: Colors.lightBlueAccent),
            SizedBox(width: 8),
            Text(
              'AquaTrack',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          const Icon(Icons.location_off, color: Colors.redAccent),
          const SizedBox(width: 14),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context
                .push('/settings'), // Redirection vers ton profil/paramètres
          ),
          const SizedBox(width: 12),
        ],
      ),

      // =========================
      // CONTENU DE LA PAGE
      // =========================
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _warningGps(),

          const SizedBox(height: 22),

          const Text(
            'Bonjour, xx',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Résumé de votre ferme piscicole',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 22),

          // =========================
          // CARTES STATISTIQUES
          // =========================
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.25,
            children: const [
              StatCard(
                icon: Icons.set_meal,
                value: '6900',
                title: 'Total poissons',
                color: Colors.blue,
              ),
              StatCard(
                icon: Icons.waves,
                value: '5/17',
                title: 'Étangs actifs',
                color: Colors.teal,
              ),
              StatCard(
                icon: Icons.pie_chart,
                value: '23.5%',
                title: 'Occupation moy.',
                color: Colors.green,
              ),
              StatCard(
                icon: Icons.water_drop,
                value: '5000',
                title: 'Barrage',
                color: Colors.indigo,
              ),
            ],
          ),

          const SizedBox(height: 25),

          // =========================
          // TÂCHES DU JOUR
          // =========================
          const Text(
            'Tâches du jour',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const _TaskCard(
            title: 'Pêche de contrôle A5',
            subtitle: 'Vérifier la densité et le poids moyen',
            priority: 'Haute',
            color: Colors.orange,
          ),

          const SizedBox(height: 12),

          const _TaskCard(
            title: 'Mesure qualité eau - Étangs B',
            subtitle: 'Relever O₂, température et couleur',
            priority: 'Moyenne',
            color: Colors.blue,
          ),

          const SizedBox(height: 25),

          // =========================
          // ACCÈS RAPIDE
          // =========================
          const Text(
            'Accès rapide',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.35,
            children: [
              _QuickCard(
                title: 'Étangs A',
                subtitle: '7 étangs • 900 m²',
                color: const Color(0xFF1976D2),
                onTap: () => context.push('/pond-list?category=A'),
              ),
              _QuickCard(
                title: 'Étangs B',
                subtitle: '5 étangs • 600 m²',
                color: const Color(0xFF009688),
                onTap: () => context.push('/pond-list?category=B'),
              ),
              _QuickCard(
                title: 'Étangs C',
                subtitle: '3 étangs • 150 m²',
                color: const Color(0xFF43A047),
                onTap: () => context.push('/pond-list?category=C'),
              ),
              _QuickCard(
                title: 'Étangs D',
                subtitle: '2 étangs • 400 m²',
                color: const Color(0xFF5E35B1),
                onTap: () => context.push('/pond-list?category=D'),
              ),
              _QuickCard(
                title: 'Barrage',
                subtitle: 'Suivi du niveau d’eau',
                color: const Color(0xFF1565C0),
                onTap: () => context.push('/dam'),
              ),
            ],
          ),
        ],
      ),

      // =========================
      // TAB BAR
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            context.go(
                '/pond-list'); // Utilisation de .go() pour la barre principale
          }
          if (index == 4) {
            context.go(
                '/occupancy'); // Utilisation de .go() pour la barre principale
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.waves),
            label: 'Étangs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Qualité',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Planning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Occupation',
          ),
        ],
      ),
    );
  }

  // =========================
  // MESSAGE GPS
  // =========================
  Widget _warningGps() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_off, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Vous n'êtes pas sur le site. La saisie de données est désactivée.",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// CARTE TÂCHE
// =========================
class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priority;
  final Color color;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.task_alt, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// CARTE ACCÈS RAPIDE
// =========================
class _QuickCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.waves, color: Colors.white, size: 28),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
