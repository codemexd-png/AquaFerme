import 'package:flutter/material.dart';
import 'screen_shared.dart';

// ─── Données mockées ──────────────────────────────────────────────────────────

class _WaterEntry {
  final String pondId;
  final String date;
  final double tempC;
  final double ph;
  final double o2;
  final String couleur;
  final String agent;

  const _WaterEntry({
    required this.pondId,
    required this.date,
    required this.tempC,
    required this.ph,
    required this.o2,
    required this.couleur,
    required this.agent,
  });
}

const _mockEntries = [
  _WaterEntry(pondId: 'A1', date: '19/05/2026', tempC: 27.0, ph: 7.0, o2: 6.5, couleur: 'Vert clair', agent: 'Yao'),
  _WaterEntry(pondId: 'B1', date: '19/05/2026', tempC: 26.5, ph: 7.0, o2: 5.8, couleur: 'Vert foncé', agent: 'Yao'),
  _WaterEntry(pondId: 'A3', date: '18/05/2026', tempC: 28.2, ph: 7.5, o2: 4.8, couleur: 'Vert clair', agent: 'Konan'),
];

// ─── Écran Qualité de l'eau ───────────────────────────────────────────────────

class WaterQualityScreen extends StatefulWidget {
  const WaterQualityScreen({super.key});

  @override
  State<WaterQualityScreen> createState() => _WaterQualityScreenState();
}

class _WaterQualityScreenState extends State<WaterQualityScreen> {
  String? _selectedEtang;
  final _tempCtrl = TextEditingController();
  final _phCtrl = TextEditingController();
  final _o2Ctrl = TextEditingController();
  final _couleurCtrl = TextEditingController();

  @override
  void dispose() {
    _tempCtrl.dispose();
    _phCtrl.dispose();
    _o2Ctrl.dispose();
    _couleurCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(double o2, double ph) {
    if (o2 < 5.0 || ph < 6.5 || ph > 8.5) return Colors.orange;
    return Colors.green;
  }

  String _statusLabel(double o2, double ph) {
    if (o2 < 5.0) return 'O₂ bas';
    if (ph < 6.5 || ph > 8.5) return 'pH anormal';
    return 'Correct';
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
          'Qualité de l\'eau',
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
          // ── Formulaire nouvelle mesure ────────────────────────────────
          SectionCard(
            title: 'Nouvelle mesure',
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedEtang,
                  decoration: screenInputDecoration('Sélectionner un étang'),
                  items: etangs
                      .map((e) => DropdownMenuItem(value: e, child: Text('Étang $e')))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedEtang = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FieldRow(
                        icon: Icons.thermostat,
                        label: 'Température (°C)',
                        controller: _tempCtrl,
                        hint: 'Ex: 27.0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FieldRow(
                        icon: Icons.science_outlined,
                        label: 'pH',
                        controller: _phCtrl,
                        hint: 'Ex: 7.2',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FieldRow(
                        icon: Icons.water_drop_outlined,
                        label: 'O₂ (mg/L)',
                        controller: _o2Ctrl,
                        hint: 'Ex: 6.5',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FieldRow(
                        icon: Icons.palette_outlined,
                        label: 'Couleur',
                        controller: _couleurCtrl,
                        hint: 'Ex: Vert clair',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Enregistrer la mesure'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Historique ────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Mesures récentes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            ),
          ),
          ..._mockEntries.map((e) => _WaterEntryCard(entry: e, statusColor: _statusColor(e.o2, e.ph), statusLabel: _statusLabel(e.o2, e.ph))),
        ],
      ),
      bottomNavigationBar: const ScreenBottomNav(currentIndex: 2),
    );
  }
}

// ─── Carte mesure eau ─────────────────────────────────────────────────────────

class _WaterEntryCard extends StatelessWidget {
  final _WaterEntry entry;
  final Color statusColor;
  final String statusLabel;

  const _WaterEntryCard({required this.entry, required this.statusColor, required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Étang ${entry.pondId}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1565C0))),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Text(entry.date, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Metric(icon: Icons.water_drop_outlined, label: 'O₂', value: '${entry.o2} mg/L', color: Colors.blue),
              const SizedBox(width: 16),
              _Metric(icon: Icons.thermostat, label: 'Temp.', value: '${entry.tempC} °C', color: Colors.orange),
              const SizedBox(width: 16),
              _Metric(icon: Icons.palette_outlined, label: 'Couleur', value: entry.couleur, color: Colors.green),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _Metric(icon: Icons.science_outlined, label: 'pH', value: '${entry.ph}', color: Colors.purple),
              const SizedBox(width: 16),
              Icon(Icons.person_outline, size: 13, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(entry.agent, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Metric({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
