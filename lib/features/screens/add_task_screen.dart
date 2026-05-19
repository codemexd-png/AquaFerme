// ─── Écran Création de tâche ─────────────────────────────────────────────────
// Formulaire permettant de créer une nouvelle tâche de planning.
// Champ "Assigner à" : Autocomplete avec saisie libre et mémorisation des noms.
// Ouvert via Navigator.push depuis PlanningScreen (pas via GoRouter : pas de route dédiée).

import 'package:flutter/material.dart';
import 'screen_shared.dart';

// ─── Écran Création de tâche ──────────────────────────────────────────────────

const _categories = ['Pêche de contrôle', 'Qualité eau', 'Nutrition', 'Nettoyage', 'Transfert', 'Mortalité', 'Autre'];
const _priorites = ['Haute', 'Moyenne', 'Basse'];

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  String? _selectedEtang;
  String? _selectedCategorie;
  String? _selectedPriorite;
  String? _selectedAgent;
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  // Options mémorisées entre les utilisations (session en cours)
  static final _agentOptions = <String>[];

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
    );
    if (picked != null) {
      _dateCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
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
          'Créer une tâche',
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
          // ── Informations générales ────────────────────────────────────
          SectionCard(
            title: 'Informations générales',
            child: Column(
              children: [
                FieldRow(
                  icon: Icons.title,
                  label: 'Titre de la tâche',
                  controller: _titreCtrl,
                  hint: 'Ex: Contrôle croissance étang A2',
                ),
                const SizedBox(height: 12),
                _LabeledDropdown(
                  label: 'Catégorie',
                  icon: Icons.category_outlined,
                  value: _selectedCategorie,
                  items: _categories,
                  hint: 'Sélectionner une catégorie',
                  onChanged: (v) => setState(() => _selectedCategorie = v),
                ),
                const SizedBox(height: 12),
                _LabeledDropdown(
                  label: 'Étang cible',
                  icon: Icons.water_outlined,
                  value: _selectedEtang,
                  items: etangs.map((e) => 'Étang $e').toList(),
                  hint: 'Sélectionner un étang',
                  onChanged: (v) => setState(() => _selectedEtang = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Planification ──────────────────────────────────────────────
          SectionCard(
            title: 'Planification',
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text('Date prévue', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _dateCtrl,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: screenInputDecoration('Ex: 21/05/2026').copyWith(
                        suffixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF1565C0)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _LabeledDropdown(
                  label: 'Priorité',
                  icon: Icons.flag_outlined,
                  value: _selectedPriorite,
                  items: _priorites,
                  hint: 'Sélectionner une priorité',
                  onChanged: (v) => setState(() => _selectedPriorite = v),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text('Assigner à', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue tv) {
                        if (tv.text.isEmpty) return _agentOptions;
                        return _agentOptions.where(
                          (a) => a.toLowerCase().contains(tv.text.toLowerCase()),
                        );
                      },
                      onSelected: (s) => setState(() => _selectedAgent = s),
                      fieldViewBuilder: (context, ctrl, focusNode, onSubmitted) => TextField(
                        controller: ctrl,
                        focusNode: focusNode,
                        decoration: screenInputDecoration('Ex: Ibrahim'),
                        onChanged: (v) => setState(() => _selectedAgent = v),
                        onSubmitted: (_) {
                          final name = ctrl.text.trim();
                          if (name.isNotEmpty && !_agentOptions.contains(name)) {
                            _agentOptions.add(name);
                          }
                          setState(() => _selectedAgent = name);
                          onSubmitted();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Description ────────────────────────────────────────────────
          SectionCard(
            title: 'Description',
            child: TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: screenInputDecoration('Détails de la tâche à effectuer...'),
            ),
          ),
          const SizedBox(height: 24),

          // ── Bouton ──────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.playlist_add_check_circle_outlined),
              label: const Text('Créer la tâche', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ScreenBottomNav(currentIndex: 3),
    );
  }
}

// ─── Helper dropdown avec label ───────────────────────────────────────────────

class _LabeledDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  const _LabeledDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          decoration: screenInputDecoration(hint),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
