import 'package:flutter/material.dart';
import 'screen_shared.dart';

// ─── Causes mockées ───────────────────────────────────────────────────────────

const _causes = [
  'Manque d\'oxygène',
  'Maladie / Parasite',
  'Stress thermique',
  'Surpopulation',
  'Mauvaise qualité eau',
  'Cause inconnue',
  'Autre',
];

// ─── Écran Déclaration de mortalité ──────────────────────────────────────────

class MortalityScreen extends StatefulWidget {
  const MortalityScreen({super.key});

  @override
  State<MortalityScreen> createState() => _MortalityScreenState();
}

class _MortalityScreenState extends State<MortalityScreen> {
  String? _selectedEtang;
  String? _selectedCause;
  final _nbCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();

  @override
  void dispose() {
    _nbCtrl.dispose();
    _detailsCtrl.dispose();
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
          'Déclaration de mortalité',
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
          // ── Alerte ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(color: Colors.orange.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Signalez toute mortalité dès que possible pour permettre une action rapide.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Étang concerné ────────────────────────────────────────────
          SectionCard(
            title: 'Étang concerné',
            child: DropdownButtonFormField<String>(
              value: _selectedEtang,
              decoration: screenInputDecoration('Sélectionner un étang'),
              items: etangs
                  .map((e) => DropdownMenuItem(value: e, child: Text('Étang $e')))
                  .toList(),
              onChanged: (v) => setState(() => _selectedEtang = v),
            ),
          ),
          const SizedBox(height: 12),

          // ── Informations ──────────────────────────────────────────────
          SectionCard(
            title: 'Informations',
            child: Column(
              children: [
                FieldRow(
                  icon: Icons.numbers,
                  label: 'Nombre de mortalités',
                  controller: _nbCtrl,
                  hint: 'Ex: 12',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text('Cause probable', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCause,
                      decoration: screenInputDecoration('Sélectionner une cause'),
                      items: _causes
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCause = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Détails ───────────────────────────────────────────────────
          SectionCard(
            title: 'Détails',
            child: TextField(
              controller: _detailsCtrl,
              maxLines: 4,
              decoration: screenInputDecoration('Symptômes observés, actions déjà prises...'),
            ),
          ),
          const SizedBox(height: 24),

          // ── Bouton ────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('Déclarer la mortalité', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ScreenBottomNav(currentIndex: 1),
    );
  }
}
