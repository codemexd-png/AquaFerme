import 'package:flutter/material.dart';

class DamScreen extends StatelessWidget {
  const DamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        title: const Text(
          'Barrage principal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HeaderCard(),
          SizedBox(height: 18),
          _DamGaugeCard(),
          SizedBox(height: 16),

          _InfoCard(
            icon: Icons.water_drop,
            title: 'Niveau actuel',
            value: '5000 m³',
            color: Colors.blue,
          ),

          SizedBox(height: 12),

          _InfoCard(
            icon: Icons.storage,
            title: 'Capacité maximale',
            value: '50 000 m³',
            color: Colors.indigo,
          ),

          SizedBox(height: 12),

          _InfoCard(
            icon: Icons.check_circle,
            title: 'Statut',
            value: 'Stable',
            color: Colors.green,
          ),

          SizedBox(height: 22),

          Text(
            'Historique récent',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 12),

          _HistoryCard(
            title: 'Contrôle du barrage',
            subtitle: 'Niveau vérifié avec succès',
            date: '19/05/2026',
          ),
        ],
      ),
    );
  }
}

// =========================
// CARTE BLEUE DU HAUT
// =========================
class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.water_drop, color: Colors.blue, size: 34),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suivi du barrage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Contrôle du niveau d’eau disponible',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// CARTE AVEC CERCLE 10%
// =========================
class _DamGaugeCard extends StatelessWidget {
  const _DamGaugeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Text(
            'Occupation du barrage',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    value: 0.10,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Color(0xFFEAEAEA),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),

                Text(
                  '10%',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            '5000 m³ utilisés',
            style: TextStyle(fontSize: 17, color: Colors.grey),
          ),

          const SizedBox(height: 4),

          const Text(
            'Capacité totale : 50 000 m³',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// =========================
// CARTE INFORMATION
// =========================
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16)),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// HISTORIQUE
// =========================
class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;

  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.history, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// =========================
// DESIGN DES CARTES
// =========================
BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.07),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}