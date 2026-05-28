import 'package:flutter/material.dart';
import 'screen_shared.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_service.dart';

// ─── Écran Qualité de l'eau ───────────────────────────────────────────────────

class WaterQualityScreen extends StatefulWidget {
  const WaterQualityScreen({super.key});

  @override
  State<WaterQualityScreen> createState() => _WaterQualityScreenState();
}

class _WaterQualityScreenState extends State<WaterQualityScreen> {
  String? _selectedEtang;
  final _tempCtrl = TextEditingController();
  final _o2Ctrl = TextEditingController();
  final _couleurCtrl = TextEditingController();
  bool _isSaving = false;

  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService.fetchWaterQuality();
      setState(() => _entries = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tempCtrl.dispose();
    _o2Ctrl.dispose();
    _couleurCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(double o2) {
    if (o2 < 5.0) return Colors.orange;
    return Colors.green;
  }

  String _statusLabel(double o2) {
    if (o2 < 5.0) return 'O₂ bas';
    return 'Correct';
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.length < 10) return '';
    final parts = iso.substring(0, 10).split('-');
    if (parts.length != 3) return iso;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  Future<void> _saveEntry() async {
    if (_selectedEtang == null) return;
    final temp = double.tryParse(_tempCtrl.text);
    final o2 = double.tryParse(_o2Ctrl.text);
    if (temp == null || o2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs numériques.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ApiService.saveWaterQuality(
        pondId: _selectedEtang!,
        temperatureC: temp,
        oxygenMgL: o2,
        waterColor: _couleurCtrl.text.trim(),
      );
      _tempCtrl.clear();
      _o2Ctrl.clear();
      _couleurCtrl.clear();
      setState(() => _selectedEtang = null);
      await _loadEntries();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Plus besoin de flèche retour si géré par la barre globale
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Qualité de l\'eau',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black87),
              onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () => context.push('/settings'),
          ),
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
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text('Étang $e')))
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isSaving ? null : _saveEntry,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add_circle_outline),
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
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87),
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.cloud_off, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('Erreur de chargement',
                      style: TextStyle(color: Colors.grey[600])),
                  TextButton.icon(
                    onPressed: _loadEntries,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          else
            ..._entries.map((e) {
              final o2 = (e['oxygen_mg_l'] as num?)?.toDouble() ?? 0.0;
              return _WaterEntryCard(
                entry: e,
                date: _formatDate(e['created_at'] as String?),
                statusColor: _statusColor(o2),
                statusLabel: _statusLabel(o2),
              );
            }),
        ],
      ),
    );
  }
}

// ─── Carte mesure eau ─────────────────────────────────────────────────────────

class _WaterEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final String date;
  final Color statusColor;
  final String statusLabel;

  const _WaterEntryCard(
      {required this.entry,
      required this.date,
      required this.statusColor,
      required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    final pondId = entry['pond_id'] as String? ?? '';
    final o2 = (entry['oxygen_mg_l'] as num?)?.toDouble() ?? 0.0;
    final tempC = (entry['temperature_c'] as num?)?.toDouble() ?? 0.0;
    final couleur = entry['water_color'] as String? ?? '';
    final notes = entry['notes'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Étang $pondId',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1565C0))),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Text(date, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Metric(
                  icon: Icons.water_drop_outlined,
                  label: 'O₂',
                  value: '$o2 mg/L',
                  color: Colors.blue),
              const SizedBox(width: 16),
              _Metric(
                  icon: Icons.thermostat,
                  label: 'Temp.',
                  value: '$tempC °C',
                  color: Colors.orange),
              const SizedBox(width: 16),
              _Metric(
                  icon: Icons.palette_outlined,
                  label: 'Couleur',
                  value: couleur,
                  color: Colors.green),
            ],
          ),
          if (notes.isNotEmpty) ...
            [
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.notes, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(notes,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
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

  const _Metric(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            Text(value,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
