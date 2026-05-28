import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Import de ton fournisseur d'état
import '../providers/app_providers.dart';
// Widget réutilisable conservé
import '../../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Lance la vérification GPS dès que le premier rendu de l'écran est prêt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().checkLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    // On écoute en temps réel l'état de géolocalisation géré par le AppProvider
    final appProvider = context.watch<AppProvider>();
    final bool isOnSite = appProvider.isOnSite;
    final bool isLoadingGPS = appProvider.isLoadingLocation;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      // =========================
      // BARRE DU HAUT
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
              'Divine alimentation',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Icône de statut de géolocalisation dynamique
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: isLoadingGPS
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    isOnSite ? Icons.location_on : Icons.location_off,
                    color: isOnSite ? Colors.greenAccent : Colors.redAccent,
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

      // =========================
      // CONTENU DE LA PAGE
      // =========================
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // La bannière d'avertissement s'affiche uniquement si l'utilisateur n'est pas sur le site
          if (!isOnSite && !isLoadingGPS) ...[
            _warningGps(),
            const SizedBox(height: 22),
          ],

// Titre de bienvenue dynamique avec le nom de l'utilisateur qui se connecte, récupéré depuis le AppProvider
          Consumer<AppProvider>(
            builder: (context, provider, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${provider.username}',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Connecté en tant que ${provider.userRole}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Résumé de votre ferme piscicole',
            style: TextStyle(color: Colors.grey, fontSize: 15),
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
            childAspectRatio: 1.0,
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.1,
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
                subtitle: "Suivi du niveau d'eau",
                color: const Color(0xFF1565C0),
                onTap: () => context.push('/dam'),
              ),
            ],
          ),

          const SizedBox(height: 16),
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
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
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
        padding: const EdgeInsets.all(14),
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
            const Icon(Icons.waves, color: Colors.white, size: 24),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
