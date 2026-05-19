import 'dart:convert';
import 'package:flutter/services.dart';

// ─── MockDataService ──────────────────────────────────────────────────────────
// Source unique de données mockées pour toute l'équipe.
// Utilisation : await MockDataService.init() dans main(), puis appels synchrones.

class MockDataService {
  MockDataService._();

  static Map<String, dynamic> _data = {};
  static bool _loaded = false;

  /// À appeler une seule fois dans main() avant runApp().
  static Future<void> init() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/mocks/seed.json');
    _data = json.decode(raw) as Map<String, dynamic>;
    _loaded = true;
  }

  // ── Employés ────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> get employes =>
      List<Map<String, dynamic>>.from(_data['employes'] as List);

  static Map<String, dynamic>? employe(String id) =>
      employes.firstWhere((e) => e['id'] == id, orElse: () => {});

  static String nomEmploye(String id) =>
      employe(id)?['nom'] as String? ?? id;

  // ── Étangs ──────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> get etangs =>
      List<Map<String, dynamic>>.from(_data['etangs'] as List);

  static Map<String, dynamic>? etang(String id) =>
      etangs.firstWhere((e) => e['id'] == id, orElse: () => {});

  static List<Map<String, dynamic>> etangsParGroupe(String groupe) =>
      etangs.where((e) => e['groupe'] == groupe).toList();

  /// Taux d'occupation entre 0.0 et 1.0
  static double occupation(String etangId) {
    final e = etang(etangId);
    if (e == null || e.isEmpty) return 0;
    final cap = (e['capaciteMax'] as num).toDouble();
    final stock = (e['stockActuel'] as num).toDouble();
    return cap > 0 ? (stock / cap).clamp(0.0, 1.0) : 0;
  }

  static int get stockTotal =>
      etangs.fold(0, (sum, e) => sum + (e['stockActuel'] as int));

  static double get occupationMoyenne {
    if (etangs.isEmpty) return 0;
    final total = etangs.fold(0.0, (sum, e) => sum + occupation(e['id'] as String));
    return total / etangs.length;
  }

  // ── Barrage ─────────────────────────────────────────────────────────────────

  static Map<String, dynamic> get barrage =>
      Map<String, dynamic>.from(_data['barrage'] as Map);

  static List<Map<String, dynamic>> get deversements =>
      List<Map<String, dynamic>>.from(barrage['deversements'] as List);

  // ── Opérations ──────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> get operations =>
      List<Map<String, dynamic>>.from(_data['operations'] as List);

  static List<Map<String, dynamic>> operationsByEtang(String etangId) =>
      operations.where((op) {
        return op['etangId'] == etangId ||
            op['etangSourceId'] == etangId ||
            op['etangDestId'] == etangId;
      }).toList()
        ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

  static List<Map<String, dynamic>> operationsByType(String type) =>
      operations.where((op) => op['type'] == type).toList()
        ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

  /// Dernière opération d'un type donné sur un étang
  static Map<String, dynamic>? derniereOperation(String etangId, String type) {
    final ops = operationsByEtang(etangId).where((op) => op['type'] == type).toList();
    return ops.isNotEmpty ? ops.first : null;
  }

  // ── Planning ────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> get planning =>
      List<Map<String, dynamic>>.from(_data['planning'] as List);

  /// Tâches d'une semaine donnée (lundi inclus → dimanche inclus)
  static List<Map<String, dynamic>> planningDeSemaine(DateTime lundi) {
    final fin = lundi.add(const Duration(days: 6));
    return planning.where((t) {
      final d = DateTime.parse(t['date'] as String);
      return !d.isBefore(lundi) && !d.isAfter(fin);
    }).toList()
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
  }

  static List<Map<String, dynamic>> planningParStatut(String statut) =>
      planning.where((t) => t['statut'] == statut).toList();

  // ── Alertes du jour ─────────────────────────────────────────────────────────

  /// Étangs dont l'occupation dépasse 90 %
  static List<Map<String, dynamic>> get alertesSuroccupation =>
      etangs.where((e) => occupation(e['id'] as String) >= 0.9).toList();

  /// Tâches du jour non faites
  static List<Map<String, dynamic>> alertesTaches(DateTime jour) {
    final dateStr = jour.toIso8601String().substring(0, 10);
    return planning
        .where((t) => t['date'] == dateStr && t['statut'] != 'fait')
        .toList();
  }
}
