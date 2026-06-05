// ─── Écran Création de tâche ─────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'screen_shared.dart';
import '../../services/api_service.dart';

const _categories = [
  'Pêche de contrôle',
  'Qualité eau',
  'Nutrition',
  'Nettoyage',
  'Transfert',
  'Mortalité',
  'Autre'
];
const _priorites = ['Haute', 'Moyenne', 'Basse'];

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  String? _selectedPondId;
  String? _selectedCategorie;
  String? _selectedPriorite;
  String? _selectedAgent;

  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  List<dynamic> _users = [];
  List<dynamic> _ponds = [];
  bool _isLoadingUsers = false;
  bool _isLoadingPonds = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadPonds();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    final users = await ApiService.getUsers();
    setState(() {
      _users = users;
      _isLoadingUsers = false;
    });
  }

  Future<void> _loadPonds() async {
    setState(() => _isLoadingPonds = true);
    try {
      final ponds = await ApiService.getPonds();
      setState(() {
        _ponds = ponds;
        _isLoadingPonds = false;
      });
    } catch (_) {
      setState(() => _isLoadingPonds = false);
    }
  }

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

  // Convertit DD/MM/YYYY → YYYY-MM-DD pour le backend
  String _convertDate(String ddmmyyyy) {
    final parts = ddmmyyyy.split('/');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  Future<void> _createTask() async {
    // Validation
    if (_titreCtrl.text.trim().isEmpty) {
      _showError('Le titre est obligatoire.');
      return;
    }
    if (_selectedCategorie == null) {
      _showError('Sélectionne une catégorie.');
      return;
    }
    if (_dateCtrl.text.isEmpty) {
      _showError('La date est obligatoire.');
      return;
    }
    if (_selectedPriorite == null) {
      _showError('Sélectionne une priorité.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ApiService.createTask(
        title: _titreCtrl.text.trim(),
        pondId: _selectedPondId,
        taskDate: _convertDate(_dateCtrl.text),
        priority: _selectedPriorite!.toLowerCase(),
        assignedTo: _selectedAgent,
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tâche créée avec succès ✓'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // true = refresh la liste
      }
    } catch (e) {
      if (mounted) _showError('Erreur : $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
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
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
                // Étang cible — chargé depuis l'API
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_outlined,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text('Étang cible (optionnel)',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _isLoadingPonds
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            value: _selectedPondId,
                            decoration:
                                screenInputDecoration('Sélectionner un étang'),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Aucun étang'),
                              ),
                              ..._ponds.map((pond) {
                                return DropdownMenuItem<String>(
                                  value: pond['id'].toString(),
                                  child: Text(
                                      pond['name'] ?? 'Étang ${pond['id']}'),
                                );
                              }),
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedPondId = v),
                          ),
                  ],
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
                        Icon(Icons.calendar_today_outlined,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text('Date prévue',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _dateCtrl,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration:
                          screenInputDecoration('Ex: 21/05/2026').copyWith(
                        suffixIcon: const Icon(Icons.calendar_month_outlined,
                            color: Color(0xFF1565C0)),
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
                        Icon(Icons.person_outline,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text('Assigner à',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _isLoadingUsers
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            value: _selectedAgent,
                            decoration: screenInputDecoration(
                                'Sélectionner un employé'),
                            items: _users.map((user) {
                              return DropdownMenuItem<String>(
                                value: user['id'].toString(),
                                child: Text(user['username']),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => _selectedAgent = v),
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
              decoration:
                  screenInputDecoration('Détails de la tâche à effectuer...'),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isSaving ? null : _createTask,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.playlist_add_check_circle_outlined),
              label: Text(
                _isSaving ? 'Enregistrement...' : 'Créer la tâche',
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
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
            Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: screenInputDecoration(hint),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
