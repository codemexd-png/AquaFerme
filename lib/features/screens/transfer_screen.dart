import 'package:flutter/material.dart';
import 'screen_shared.dart';

// ─── Motifs mockés ────────────────────────────────────────────────────────────

const _motifs = [
  'Équilibrage de densité',
  'Croissance trop rapide',
  'Étang en maintenance',
  'Préparation récolte',
  'Séparation par taille',
  'Autre',
];

// ─── Écran Transfert de poissons ──────────────────────────────────────────────

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String? _etangSource;
  String? _etangDest;
  String? _motif;
  final _nbCtrl = TextEditingController();
  final _poidsCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _nbCtrl.dispose();
    _poidsCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transfert de poissons',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Source → Destination ──────────────────────────────────────
          SectionCard(
            title: 'Transfert',
            child: Column(
              children: [
                // Source
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.login_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text('Étang source', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _etangSource,
                      decoration: screenInputDecoration('Sélectionner l\'étang source'),
                      items: etangs
                          .map((e) => DropdownMenuItem(value: e, child: Text('Étang $e')))
                          .toList(),
                      onChanged: (v) => setState(() => _etangSource = v),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Flèche centrale
                const Icon(Icons.swap_vert, color: Color(0xFF1565C0), size: 28),
                const SizedBox(height: 8),

                // Destination
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.logout_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text('Étang destination', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _etangDest,
                      decoration: screenInputDecoration('Sélectionner l\'étang destination'),
                      items: etangs
                          .where((e) => e != _etangSource)
                          .map((e) => DropdownMenuItem(value: e, child: Text('Étang $e')))
                          .toList(),
                      onChanged: (v) => setState(() => _etangDest = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Quantités ────────────────────────────────────────────────
          SectionCard(
            title: 'Quantités',
            child: Row(
              children: [
                Expanded(
                  child: FieldRow(
                    icon: Icons.set_meal,
                    label: 'Nombre de poissons',
                    controller: _nbCtrl,
                    hint: 'Ex: 300',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FieldRow(
                    icon: Icons.scale,
                    label: 'Poids moyen (g)',
                    controller: _poidsCtrl,
                    hint: 'Ex: 95',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Motif ────────────────────────────────────────────────────
          SectionCard(
            title: 'Motif du transfert',
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _motif,
                  decoration: screenInputDecoration('Sélectionner un motif'),
                  items: _motifs
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _motif = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: screenInputDecoration('Note additionnelle (optionnel)...'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Bouton ────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Valider le transfert', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ScreenBottomNav(currentIndex: 1),
    );
  }
}
