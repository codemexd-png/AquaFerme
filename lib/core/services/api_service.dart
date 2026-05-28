// ─── Service HTTP centralisé ──────────────────────────────────────────────────
// Point d'entrée unique pour toutes les requêtes vers le backend REST.
// ⚠️  Adapter _baseUrl selon l'environnement :
//     - Émulateur Android  → 'http://10.0.2.2:3000'
//     - Simulateur iOS     → 'http://localhost:3000'
//     - Appareil physique  → 'http://<IP_DU_SERVEUR>:3000'

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/task.dart'; //

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000'; //on doit changer _baseUrl selon ton environnement (émulateur Android = 10.0.2.2, appareil physique = l'IP réelle du serveur).

  // ── Tâches ────────────────────────────────────────────────────────────────

  /// GET /tasks → liste de toutes les tâches
  static Future<List<Task>> fetchTasks() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/tasks'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erreur serveur (${response.statusCode}) : /tasks');
  }

  // ── Qualité de l'eau ──────────────────────────────────────────────────────

  /// GET /water-quality → liste des mesures
  static Future<List<Map<String, dynamic>>> fetchWaterQuality() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/water-quality'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception(
        'Erreur serveur (${response.statusCode}) : /water-quality');
  }

  /// POST /water-quality → enregistre une nouvelle mesure
  static Future<void> saveWaterQuality({
    required String pondId,
    required double temperatureC,
    required double oxygenMgL,
    required String waterColor,
    String? notes,
  }) async {
    final body = json.encode({
      'pond_id': pondId,
      'temperature_c': temperatureC,
      'oxygen_mg_l': oxygenMgL,
      'water_color': waterColor,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });

    final response = await http
        .post(
          Uri.parse('$_baseUrl/water-quality'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Erreur serveur (${response.statusCode}) : POST /water-quality');
    }
  }
}