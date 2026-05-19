import 'package:flutter/material.dart';

// ─── Données mockées ──────────────────────────────────────────────────────────

const _etangs = ['A1', 'A2', 'A3', 'A4', 'A5', 'B1', 'B2', 'B3', 'B4', 'B5', 'C1', 'C2', 'C3', 'D1', 'D2'];

// ─── Écran Pêche de contrôle ───────────────────────────────────────────────────

class AddOperationScreen extends StatefulWidget {
  const AddOperationScreen({super.key});

  @override
  State<AddOperationScreen> createState() => _AddOperationScreenState();
}

class _AddOperationScreenState extends State<AddOperationScreen> {
  String? _selectedEtang;
  final _poidsCtrl = TextEditingController();
  final _nbCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void dispose() {
    _poidsCtrl.dispose();
    _nbCtrl.dispose();
    _obsCtrl.dispose();
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
          'Pêche de contrôle',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── En-tête étang ────────────────────────────────────────────────
          _SectionCard(
            title: 'Étang concerné',
            child: DropdownButtonFormField<String>(
              value: _selectedEtang,
              decoration: _inputDecoration('Sélectionner un étang'),
              items: _etangs
                  .map((e) => DropdownMenuItem(value: e, child: Text('Étang $e')))
                  .toList(),
              onChanged: (v) => setState(() => _selectedEtang = v),
            ),
          ),
          const SizedBox(height: 12),

          // ── Mesures ──────────────────────────────────────────────────────
          _SectionCard(
            title: 'Mesures',
            child: Column(
              children: [
                _FieldRow(
                  icon: Icons.scale,
                  label: 'Poids moyen (g)',
                  controller: _poidsCtrl,
                  hint: 'Ex: 120',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _FieldRow(
                  icon: Icons.set_meal,
                  label: 'Nombre échantillonné',
                  controller: _nbCtrl,
                  hint: 'Ex: 50',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Observations ─────────────────────────────────────────────────
          _SectionCard(
            title: 'Observation',
            child: TextField(
              controller: _obsCtrl,
              maxLines: 4,
              decoration: _inputDecoration('État général, comportement, remarques...'),
            ),
          ),
          const SizedBox(height: 24),

          // ── Bouton ───────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.save_outlined),
              label: const Text('Enregistrer l\'opération', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 3),
    );
  }
}

// ─── Helpers partagés ─────────────────────────────────────────────────────────

InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1565C0)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1565C0))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _FieldRow({
    required this.icon,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }
}

// ─── Barre de navigation commune ─────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1565C0),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      onTap: (_) {},
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Tableau de bord'),
        BottomNavigationBarItem(icon: Icon(Icons.water_outlined), label: 'Étangs'),
        BottomNavigationBarItem(icon: Icon(Icons.water_drop_outlined), label: 'Qualité eau'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Planning'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Occupation'),
      ],
    );
  }
}
