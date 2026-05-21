import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      // ─── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        title: const Text(
          'Paramètres',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          // ─── Avatar + Nom + Rôle ───────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFF455A64),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'X',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'xx',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Personnel',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 20),

          // ─── Géolocalisation ───────────────────────────────────────────────
          _SettingsSection(
            icon: Icons.location_on,
            iconColor: Colors.red,
            title: 'Géolocalisation',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    'Vous êtes à 7470550 m du site.\nVous devez être à moins de 500 m pour saisir des données.',
                    style: TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    context.read<AppProvider>().checkLocation();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0D47A1)),
                    foregroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Vérifier'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // ─── À propos de la ferme ──────────────────────────────────────────
          _SettingsSection(
            icon: Icons.info_outline,
            iconColor: Colors.blueGrey,
            title: 'À propos de la ferme',
            child: const Text(
              '16 étangs + 1 barrage (50 000 m²)',
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),

          const SizedBox(height: 20),

          // ─── Configuration ─────────────────────────────────────────────────
          _SettingsSection(
            icon: Icons.tune,
            iconColor: Colors.blueGrey,
            title: 'Configuration',
            child: const Text(
              '8 × A (900m²) · 5 × B (600m²) · 3 × C (150m²) · 2 × D (400m²)',
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // ─── Version ───────────────────────────────────────────────────────
          _SettingsSection(
            icon: Icons.code,
            iconColor: Colors.blueGrey,
            title: 'Version',
            child: const Text(
              'AquaTrack v1.0.0',
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),

          const SizedBox(height: 32),

          // ─── Se déconnecter ────────────────────────────────────────────────
          GestureDetector(
            onTap: () {
              // TODO : logique de déconnexion
              context.go('/');
            },
            child: const Row(
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 12),
                Text(
                  'Se déconnecter',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget section réutilisable ──────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SettingsSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              child,
            ],
          ),
        ),
      ],
    );
  }
}
